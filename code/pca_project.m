function subspace_data = pca_project(features, pca_parms, D)
N = size(features,2);
subspace_data = pca_parms.base(:,1:D)' * (features - pca_parms.origin*ones(1,N));