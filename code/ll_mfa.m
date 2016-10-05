function [ LogL, proj,lat_covs ] = ll_mfa(X,mfa,X2)
%
% function [ LogL, proj ] = mppca_gauss(X,M,W,Psi);
%
% computes log-likelihoods of X under Gaussians
% also returns the inferred latent coordinates
%
% X (D x N)     - n d-dimensional data
% mfa is a struct with the fields:
% M (D x C)     - k d-dimensional means
% W (D x d x C) - for each Gaussian q d-dim vectors
% Psi (D,C)     - diagonal noise levels

N         = size(X,2);
[D, d, C] = size(mfa.W);

proj = zeros(d,N,C);
lat_covs = zeros(d,d,C);

if nargin==2; X2 = X.^2;end

if d==0    
    psiI   = mfa.Psi.^-1;
    
    LogL  = (-0.5*psiI)'*X2; clear X2;
    LogL  = LogL  + (psiI.*mfa.M)'*X;
            
    tmp   = sum(psiI.*(mfa.M.^2) , 1) - sum(log(psiI),1)+ D*log(2*pi);
    LogL  = bsxfun(@minus,LogL,0.5*tmp');    
else
    LogL = zeros(C,N);

    for c = 1:C
        w             = mfa.W(:,:,c);
        psi           = mfa.Psi(:,c);
        
        psiI          = psi.^-1;
        psiIw         = repmat(psiI, 1,d) .* w;
        lat_cov       = inv( eye(d) + w'* psiIw );
        
        psiI_w_xc     = psiIw' * X - repmat(psiIw'*mfa.M(:,c),1,N);
        proj(:,:,c)   = lat_cov * psiI_w_xc;
        
        log_det       = sum(log(psi)) - log(det(  lat_cov ));
        
        energy        = psiI'*X2;
        energy        = energy + psiI'*(mfa.M(:,c).^2);
        energy        = energy -2*(psiI.*mfa.M(:,c))'*X;
        if d>0
            energy = energy - sum( psiI_w_xc .* (lat_cov*psiI_w_xc) ,1);
        end
        
        energy        = -energy / 2;
        
        LogL(c,:)     = energy -.5*log_det -(D/2)*log(2*pi);
        
        lat_covs(:,:,c) = lat_cov;
    end           
end