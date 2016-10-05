function parms = get_svm_results(parms)

if (isempty(parms.svm_results))
    assert(~isempty(parms.svm_results_filename));
    if (exist(parms.svm_results_filename,'file'))
        tmp = load(parms.svm_results_filename);
        parms.svm_results = tmp.svm_results;        
        clear tmp;
    else        
        parms = get_gramm_matrices(parms);
        parms = learn_svm(parms);
        parms.svm_results.test_scores = zeros(parms.n_test_images, parms.n_class);
        for class_id = 1:parms.n_class
            [~, perf, test_scores] = svmpredict(parms.class_labels(parms.test_indices,class_id), [(1:parms.n_test_images)' parms.gramm_matrix_test], parms.svm_models{class_id});
            test_scores = parms.class_labels(parms.train_indices(1), class_id) * test_scores; % libSVM thing: multiply the scores by the label of 1st training example
            parms.svm_results.test_scores(:,class_id) = test_scores;
            [parms.svm_results.ap(class_id), parms.svm_results.acc(class_id), ~] =  ...
                get_performance_measures(test_scores, parms.class_labels(parms.test_indices,class_id), [1 -1]);
            % assert(perf(1) == parms.svm_results.acc(class_id));
        end   
        save(parms.svm_results_filename,'-struct','parms','svm_results');
    end
end


