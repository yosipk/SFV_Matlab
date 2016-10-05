function parms = sample_training_features(parms)

if (isempty(parms.training_features))
    assert(~isempty(parms.training_features_filename));
    if (exist(parms.training_features_filename,'file'))
        fprintf('Loading cached training features from %s\n', parms.training_features_filename);
        tmp = load(parms.training_features_filename);
        parms.training_features = tmp.training_features;
        clear tmp;
    else        
        image_sizes_filename = sprintf('%s/labels/image_sizes.list', parms.root_dir);
        image_sizes = load(image_sizes_filename);

        feat_per_image = distribute_equally(parms.n_train_feat, parms.n_train_images);

        parms.training_features.appearance = zeros(parms.feat_dim_orig, parms.n_train_feat);
        parms.training_features.position = zeros(2,parms.n_train_feat);

        first_feature_index = 1;
        for n = 1:parms.n_train_images            
            image_indice = parms.train_indices(n);
            image_size = image_sizes(image_indice,:);
            train_data = load(sprintf('%s/data/%06d.mat',parms.root_dir, image_indice));
            n_feat_cur = size(train_data.f,2);
            assert(size(train_data.d,1)==parms.feat_dim_orig);
            train_data.d = double(train_data.d);
            train_data_sq = train_data.d.^2;
            zerovec_indices = find(sum(train_data_sq)==0);
            nonzerovec_indices = find(sum(train_data_sq)~=0);
            train_data.d(:,nonzerovec_indices) = bsxfun(@rdivide, train_data.d(:,nonzerovec_indices), sqrt(sum(train_data_sq(:,nonzerovec_indices))));
            train_data.d(:,zerovec_indices) = zeros(parms.feat_dim_orig, length(zerovec_indices));
            last_feature_index = first_feature_index + feat_per_image(n) - 1;            
            parms.training_features.appearance(:,first_feature_index:last_feature_index) = train_data.d(:,randsample(n_feat_cur,feat_per_image(n)));
            parms.training_features.position(:,first_feature_index:last_feature_index) = train_data.f(1:2,randsample(n_feat_cur,feat_per_image(n))) ...
                ./ (image_size' * ones(1,feat_per_image(n)));
            fprintf('Sampled %d from %d/%d training image\r',feat_per_image(n),n,parms.n_train_images);
            first_feature_index = last_feature_index + 1;
        end
        fprintf('\n');
        save(parms.training_features_filename,'-struct','parms','training_features');
    end
end
