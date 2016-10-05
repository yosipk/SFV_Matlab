function parms = learn_svm(parms)

if (isempty(parms.svm_models))
    assert(~isempty(parms.svm_models_filename));
    if (exist(parms.svm_models_filename,'file'))
        tmp = load(parms.svm_models_filename);
        parms.svm_models = tmp.svm_models;        
        clear tmp;
    else
        parms = get_gramm_matrices(parms);        
        parms = set_class_labels(parms);        
        parms.svm_models = cell(1,parms.n_class);
        parms.svm_parms = sprintf('-s 0 -t 4 -c %f', parms.svm_parm_c);
        for class_id = 1:parms.n_class 
            parms.svm_models{class_id} = svmtrain(parms.class_labels(parms.train_indices,class_id), [(1:parms.n_train_images)' parms.gramm_matrix_train], parms.svm_parms);
        end       
        save(parms.svm_models_filename,'-struct','parms','svm_models');
    end
end