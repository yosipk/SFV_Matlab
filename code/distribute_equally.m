function [distributed_discrete_vals] = distribute_equally(sum_vals, n_vals)

avg_val = sum_vals / n_vals;
min_val = floor(avg_val);
surplus = sum_vals - min_val * n_vals;
distributed_discrete_vals = min_val * ones(1,n_vals);
% select surplus random dimensions that will be increased by 1
selected_dims = randsample(1:n_vals,surplus);
distributed_discrete_vals(selected_dims) = ...
    distributed_discrete_vals(selected_dims) + 1;


