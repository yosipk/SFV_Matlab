function [position_hardassign, cells_per_quantization] = spm_assign(fPos, sgm_model) 
% N x L (L = # of qunatizations of image space)

C = length(sgm_model.quantization);
Q = length(unique(sgm_model.quantization));
N = size(fPos,2);

cells_per_quantization = zeros(1,Q);
position_hardassign = zeros(N,Q);

for q = 1:Q
    cells_per_quantization(q) = sum(sgm_model.quantization == q);
    quantization_model = sgm_model.M(:,sgm_model.quantization == q);
    [~, position_hardassign(:,q)] = max(bsxfun(@minus,fPos'*quantization_model,sum(quantization_model.^2,1)/2),[],2);      
end
