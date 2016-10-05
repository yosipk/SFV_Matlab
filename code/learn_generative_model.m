function parms = learn_generative_model(parms)

% learn subspace
if (isempty(parms.appearance_subspace))
    assert(~isempty(parms.appearance_subspace_filename));
    if (parms.feat_dim_orig ~= parms.feat_dim_proj) 
        if (exist(parms.appearance_subspace_filename,'file'))
            fprintf('Loading cached appearance subspace from %s\n', parms.appearance_subspace_filename);
            tmp = load(parms.appearance_subspace_filename);
            parms.appearance_subspace = tmp.appearance_subspace;
            clear tmp;
        else
            parms = sample_training_features(parms);
            parms.appearance_subspace = get_pca(parms.training_features.appearance);        
            save(parms.appearance_subspace_filename,'-struct','parms','appearance_subspace');
        end
    else
        parms.appearance_subspace.base = eye(parms.feat_dim_orig);
        parms.appearance_subspace.origin = zeros(parms.feat_dim_orig, 1);
        fprintf('Not performing PCA of local features as original dimension is equal to projected dimension\n');
    end
end

% learn appearance model
if (isempty(parms.appearance_model))
    assert(~isempty(parms.appearance_model_filename));
    if (exist(parms.appearance_model_filename,'file'))
        fprintf('Loading cached appearance model from %s\n', parms.appearance_model_filename);
        tmp = load(parms.appearance_model_filename);
        parms.appearance_model = tmp.appearance_model;
        clear tmp;
    else
        parms = sample_training_features(parms);               
        appearance_projected = pca_project(parms.training_features.appearance, parms.appearance_subspace, parms.feat_dim_proj);    
        if (strcmp(parms.appearance_model_type,'GMM'))
            % [~, parms.appearance_model, ~] = mfa(appearance_projected, 0, parms.appearance_components, 0, 0, 1);
            [w, mu, sigma] = yael_gmm(appearance_projected, parms.appearance_components, ...
                                      'redo', 10, ...
                                      'niter', 20, ...
                                      'seed', now);
            parms.appearance_model.mix = w';
            parms.appearance_model.M = mu;
            parms.appearance_model.Psi = sigma;
            parms.appearance_model.W = zeros(size(mu,1),0,size(mu,2));
            clear w; clear mu; clear sigma;
            % [~, parms.appearance_model, appearance_softassign] = mfa(appearance_projected, 0, parms.appearance_components, 0, 0, 1);            
            % [~,appearance_assign] = max(appearance_softassign,[],1); clear appearance_softassign;
            % appearance_assign = appearance_assign';
        elseif (strcmp(parms.appearance_model_type,'MULTINOMIAL'))
            kmeans.n_iter = 5;
            kmeans.n_chunks = 20; % increase if you run out of memory            
            [appearance_assign, parms.appearance_model.M] = kmeans_our(appearance_projected, parms.appearance_components, kmeans.n_iter, kmeans.n_chunks);
            if (kmeans.n_chunks > 5)
                parms.appearance_model.mix = zeros(parms.appearance_components,1);
                for k = 1:parms.appearance_components; parms.appearance_model.mix(k) = mean(appearance_assign == k); end
            else
                parms.appearance_model = mean(accumarray([(1:parms.n_train_feat)' appearance_assign],1,[parms.n_train_feat parms.appearance_components]),1)';    
            end    
            % [appearance_assign parms.appearance_model.M] = kmeans_our(appearance_projected, parms.appearance_components, kmeans.n_iter, kmeans.n_chunks);
            clear kmeans;
        else
            error('Unknown appearence model type');
        end        
        save(parms.appearance_model_filename,'-struct','parms','appearance_model');
    end
end

% learn/set spatial model
if (isempty(parms.spatial_model))
    assert(~isempty(parms.spatial_model_filename));
    if (exist(parms.spatial_model_filename,'file'))
        fprintf('Loading cached spatial model from %s\n', parms.spatial_model_filename);
        tmp = load(parms.spatial_model_filename);
        parms.spatial_model = tmp.spatial_model;
        clear tmp;
    else
        if (parms.learn_spatial_model)                        
            % compute spatial model per appearance component            
            % parms.spatial_model = learn_spatial_model(parms, appearance_assign);            
            error('Not refactored yet');
        else
            % use the fixed, shared model for all appearance components
            parms.spatial_model = set_spatial_model(parms);
        end
        clear appearance_assign;
        save(parms.spatial_model_filename,'-struct','parms','spatial_model');
    end
end
    
% learn normalizer
if (isempty(parms.normalizer))
    assert(~isempty(parms.normalizer_filename));
    if (exist(parms.normalizer_filename,'file'))
        fprintf('Loading cached normalizer from %s\n', parms.normalizer_filename);
        tmp = load(parms.normalizer_filename);
        parms.normalizer = tmp.normalizer;
        clear tmp;
    else       
        parms = sample_training_features(parms);               
        appearance_projected = pca_project(parms.training_features.appearance, parms.appearance_subspace, parms.feat_dim_proj);              
        parms.normalizer = parms.imagevec_function(parms.training_features.position, appearance_projected, parms.appearance_model, parms.spatial_model, parms.normalizer);
        parms.normalizer.additive = -parms.normalizer.additive; % we need to subtract the mean vector
        parms.normalizer = parms.imagevec_function(parms.training_features.position, appearance_projected, parms.appearance_model, parms.spatial_model, parms.normalizer);
        save(parms.normalizer_filename,'-struct','parms','normalizer');
    end
end