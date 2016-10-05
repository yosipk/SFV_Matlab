function	[Q, LogL, Lats, lat_covs] = mfa_E_step(X,mfa,X2); % E-step
%
% [Q, LogL, Lats, lat_covs] = mfa_E_step(X,mfa,X2); % E-step
%

if (nargin < 3)
    [L, Lats, lat_covs] = ll_mfa(X,mfa);
else
    [L, Lats, lat_covs] = ll_mfa(X,mfa,X2);
end

L  = bsxfun(@plus,L,log(mfa.mix+realmin));

Q    = bsxfun(@minus,L,max(L,[],1));
Q    = exp(Q)+realmin;
sQ   = sum(Q,1);
Q    = bsxfun(@rdivide,Q,sQ);

if (nargout > 1)
    C = size(Q,1);
    LogL  = ones(1,C)*(Q.*(L-log(Q+realmin)));    
end


