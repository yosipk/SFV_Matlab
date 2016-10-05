% requires set: root_dir, libsvm_path, yael_path

parms.root_dir = root_dir;

parms = set_train_labels(parms);

% -- features for training generative model

fields_vals_tuples = {{'feat_dim_orig', 128}, ...
                      {'n_train_feat', 5*1e5}};
parms = set_parms(parms, fields_vals_tuples);

% create parameter set code ... 
code = '';
code_trainfeat = create_code(fields_vals_tuples);

% ... append it to file
fields_vals_tuples = {{'training_features_filename',sprintf('%s/cache/training_features%s.mat', parms.root_dir, code_trainfeat)}, ...
                      {'training_features',[]}};
parms = set_parms(parms, fields_vals_tuples);

% -- subspace ---

% fields_vals_tuples = {{'feat_dim_proj', 64}};
fields_vals_tuples = {{'feat_dim_proj', 80}};
parms = set_parms(parms, fields_vals_tuples);
code_subspace = create_code(fields_vals_tuples);
code_subspace = strcat(code_trainfeat, code_subspace);
fields_vals_tuples = {{'appearance_subspace_filename',sprintf('%s/cache/appearance_subspace%s.mat', parms.root_dir, code_subspace)}, ...
                      {'appearance_subspace', []}};
parms = set_parms(parms, fields_vals_tuples);

% --- generative appearance model (dictionary) ---

fields_vals_tuples = {{'appearance_model_type','GMM'}, ... % 'MULTINOMIAL' (bins determined by k-means)
                      {'appearance_components', 256}};
parms = set_parms(parms, fields_vals_tuples);
code_appearance_genmodel = create_code(fields_vals_tuples);
code_appearance_genmodel = strcat(code_subspace, code_appearance_genmodel);
fields_vals_tuples = {{'appearance_model_filename', sprintf('%s/cache/appearance_model%s.mat' ,parms.root_dir, code_appearance_genmodel)}, ...
                      {'appearance_model', []}};
parms = set_parms(parms, fields_vals_tuples);

% --- generative spatial model ---

fields_vals_tuples = {{'spatial_model_type', 'GMM'}, ... % 'MULTINOMIAL' (bins determined by a quad-tree), GMM
                      {'spatial_components', '1'}, ... % 1 (full) + 4 (quadrants) +3 (horizontal strips)
                      {'learn_spatial_model', 0}};
parms = set_parms(parms, fields_vals_tuples);
code_spatial_genmodel = create_code(fields_vals_tuples);
code = strcat(code_appearance_genmodel, code_spatial_genmodel);
if (parms.learn_spatial_model)
  fields_vals_tuples = {{'spatial_model_filename', sprintf('%s/cache/spatial_model%s.mat', parms.root_dir, code)}, ...
                        {'spatial_model', []}};
else
  fields_vals_tuples = {{'spatial_model_filename', sprintf('%s/cache/spatial_model%s.mat', parms.root_dir, code_spatial_genmodel)}, ...
                        {'spatial_model', []}};
end 
parms = set_parms(parms, fields_vals_tuples);

% --- normalizer ---

fields_vals_tuples = {{'normalizer_filename', sprintf('%s/cache/normalizer%s.mat', parms.root_dir, code)}, ...
                      {'normalizer', []}};        
parms = set_parms(parms, fields_vals_tuples);

% -- learn subspaces, generative models and whitening normalizer

addpath(yael_path)

parms = get_imagevecs_parms(parms);
parms = learn_generative_model(parms);

% --- image vectors

fields_vals_tuples = {{'image_vectors_filename', sprintf('%s/cache/image_vectors%s.mat', parms.root_dir, code)}, ...
                      {'image_vectors', []}};
parms = set_parms(parms, fields_vals_tuples);

% TODO: remove after testing
parms = get_image_vectors(parms);

% -- gramm matrices 

fields_vals_tuples = {{'transform_imagevecs', 'ADD+MULT+POWER0.5+METRIC2'}, ...
                      {'kernel_type', 'LINEAR'}};  % CHISQ, INTERSECT, RBF-CHISQ, RBF-L2                      
parms = set_parms(parms, fields_vals_tuples);

cur_code = create_code(fields_vals_tuples);
code = strcat(code,cur_code);

fields_vals_tuples = {{'gramm_matrices_filename', sprintf('%s/cache/gramm_matrices%s.mat', parms.root_dir, code)}, ...
                      {'gramm_matrix_train', []}, ...
                      {'gramm_matrix_test', []}};
parms = set_parms(parms, fields_vals_tuples);

% TODO: remove after testing
parms = get_gramm_matrices(parms);

% -- models and results

addpath(libsvm_path);

fields_vals_tuples = {{'svm_parm_c', 1}};
parms = set_parms(parms, fields_vals_tuples);

cur_code = create_code(fields_vals_tuples);
code = strcat(code,cur_code);

fields_vals_tuples = {{'svm_models_filename', sprintf('%s/cache/svm_models%s.mat', parms.root_dir, code)}, ...
                      {'svm_models',[]}, ...
                      {'svm_results_filename', sprintf('%s/cache/svm_results%s.mat', parms.root_dir, code)}, ...
                      {'svm_results', []}};
parms = set_parms(parms, fields_vals_tuples);

parms = learn_svm(parms);

parms = get_svm_results(parms);
