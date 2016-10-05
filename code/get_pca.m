function pca_parms = get_pca(features)
% features - D_orig x N

N = size(features,2);
pca_parms.origin = mean(features,2);
[eigvecs, eigvals] = eig((features-pca_parms.origin*ones(1,N))*(features-pca_parms.origin*ones(1,N))');
[~,col_idx] = sort(diag(eigvals),'descend');
pca_parms.base = eigvecs(:,col_idx);