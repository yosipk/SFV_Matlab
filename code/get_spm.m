function image_vector = get_spm(fPos, fApp, agm_model, sgm_model, normalizer)

if ~isfield(normalizer,'additive')
    get_normalizer='additive';
elseif ~isfield(normalizer,'multiplicative')
    assert(isfield(normalizer,'additive'));
    get_normalizer='multiplicative';
else
    get_normalizer='';
end

[position_hardassign, cellsPerLevel] = spm_assign(fPos,sgm_model); % N x L (L = # of qunatizations of image space)
app_assign = appearance_assign(fApp, agm_model); % N x K

TotalNrCells = sum(cellsPerLevel);
L = length(cellsPerLevel);

if (isfield(agm_model,'Psi'))
    fisherApp = true;
    K = numel(agm_model.mix);
    assert(size(agm_model.M,2)==K);
    D = size(agm_model.M,1);
    assert(size(fApp,1)==D);
    dims_per_word= 2*D+1;
else
    fisherApp = false;
    K = size(agm_model.M,2);
    D = size(agm_model.M,1);
    assert(size(fApp,1)==D);
    dims_per_word = 1; 
end
image_vector = zeros(K*TotalNrCells*dims_per_word,1);

CellIndx = 1:(K*dims_per_word);
for l = 1:L
    curLevelPosHardAssign = position_hardassign(:,l);
    for c = 1:cellsPerLevel(l)        
                
        if (fisherApp)            
            image_vector(CellIndx) = get_model_parameters_gradients(fApp, agm_model, bsxfun(@times,app_assign,position_hardassign(:,l)==c), get_normalizer);            
        else            
            t1 = sparse(curLevelPosHardAssign==c);
            t = bsxfun(@times,app_assign,t1);
            image_vector(CellIndx) = mean(t,1); % mean of (x squared) = mean of x, so no need to check get_normalizer = multiplicative / additive                        
        end
   
        CellIndx = CellIndx + (K*dims_per_word);
    end
end

if strcmp(get_normalizer,'additive')
    normalizer.additive = image_vector; % store the computed normalizer
    image_vector = normalizer;          % return normalizer
elseif strcmp(get_normalizer,'multiplicative')
    normalizer.multiplicative =  image_vector -normalizer.additive.^2 ; % compute variance
    ii = normalizer.multiplicative < 1e-10;                             % check for (almost) zero variances, possibly negatives when numerical error yields negative variance estimates    
    normalizer.multiplicative = 1./sqrt(normalizer.multiplicative);     % store inverse standard deviations    
    normalizer.multiplicative(ii) = 0;                                  % set to zero any components with near zero variances, effectively deleted from the representation 
    image_vector = normalizer;                                          % return normalizer
end