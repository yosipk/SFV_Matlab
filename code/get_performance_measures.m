function [ap,acc_0,acc_eer] = get_performance_measures(scores,labels,label_set)

N = length(scores);
assert(length(scores)==numel(scores));
assert(N == length(labels));
% for relevance ranking: label_set(1) is 'relevant', others 'not relevant'
[~,idx] = sort(scores,'descend');
ap = mean((1:sum(labels==label_set(1)))'./sort(find(labels(idx)==label_set(1)),'ascend'));
% for binary classification: label_set(1) is +, label_set(2) is - 
labels_pred = label_set(1)*(scores>=0) + label_set(2)*(scores<0);
acc_0 = mean(labels_pred == labels);
% for classification accuracy at EER
Np = sum(labels==label_set(1));
acc_eer = sum(labels(idx(1:Np))==label_set(1)) / Np;
% --- check if this threshold produces #fp=#fn ---
% sum(labels(idx(1:Np))==label_set(2))
% sum(labels(idx(Np+1:end))==label_set(1))