function image_vector = get_asfv(fPos, fApp, agm_model, sgm_model, normalizer)

if ~isfield(normalizer,'additive')
    get_normalizer='additive';
elseif ~isfield(normalizer,'multiplicative')
    get_normalizer='multiplicative';
else
    get_normalizer='';
end

K = numel(agm_model.mix);
assert(size(agm_model.M,2)==K);
D = size(agm_model.M,1);
assert(size(fApp,1)==D);

assert(size(sgm_model.M,1) == 2);
assert(size(fPos,1)==2);

C = numel(sgm_model.mix);

spa_dims_per_word = C * (2*2 + 1);
app_dims_per_word = 2 * D + 1;

spa_assign = (mfa_E_step(fPos,sgm_model))'; % N x C
app_assign = (mfa_E_step(fApp,agm_model))'; % N x K

image_vector = zeros(K*(app_dims_per_word + spa_dims_per_word),1);
               
image_vector(1:K*app_dims_per_word) = get_model_parameters_gradients(fApp, agm_model, app_assign, get_normalizer); 

CellIndx = K*app_dims_per_word + (1:spa_dims_per_word);
for k = 1:K                
    image_vector(CellIndx) = get_model_parameters_gradients(fPos, sgm_model, bsxfun(@times,spa_assign,app_assign(:,k)), get_normalizer);        
    CellIndx = CellIndx + spa_dims_per_word;    
end

if strcmp(get_normalizer,'additive')
    normalizer.additive = image_vector; % store the computed normalizer
    image_vector = normalizer;          % return normalizer
elseif strcmp(get_normalizer,'multiplicative')
    normalizer.multiplicative =  image_vector - normalizer.additive.^2 ; % compute variance
    ii = normalizer.multiplicative < 1e-10;                             % check for (almost) zero variances, possibly negatives when numerical error yields negative variance estimates    
    normalizer.multiplicative = 1./sqrt(normalizer.multiplicative);     % store inverse standard deviations    
    normalizer.multiplicative(ii) = 0;                                  % set to zero any components with near zero variances, effectively deleted from the representation 
    image_vector = normalizer;                                          % return normalizer
end