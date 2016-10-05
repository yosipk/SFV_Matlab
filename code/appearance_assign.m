function appearance_assign = appearance_assign(fApp, agm_model) 
% N x K

N = size(fApp,2);

assert(isfield(agm_model,'mix'));
assert(isfield(agm_model,'M'));

if (isfield(agm_model,'Psi')) % gmm
    K = numel(agm_model.mix);
    assert(size(agm_model.M,2)==K);
    D = size(agm_model.M,1);
    % assert(size(fApp,1)==D);
    appearance_assign = (mfa_E_step(fApp, agm_model))';
else % k-means    
    K = size(agm_model.M,2);
    D = size(agm_model.M,1);
    assert(size(fApp,1)==D);
    
    if (N > 20000)        
        N_chunks = 10;
        chunk_size = floor(N / N_chunks);
        appearance_assign = zeros(N,1);
        chunk_begin = 1;
        for ch_id = 1:N_chunks-1
            chunk_end = chunk_begin + chunk_size - 1;
            [~, appearance_assign_chunk] = min( sqdist(fApp(:,chunk_begin:chunk_end),agm_model.M), [], 2 ); % MEMORY    
            appearance_assign(chunk_begin:chunk_end) = appearance_assign_chunk;
            chunk_begin = chunk_end + 1;
        end
        chunk_end = N;
        [~, appearance_assign_chunk] = min( sqdist(fApp(:,chunk_begin:chunk_end),agm_model.M), [], 2 ); % MEMORY    
        appearance_assign(chunk_begin:chunk_end) = appearance_assign_chunk;        
    else                              
        [~, appearance_assign]   = max(bsxfun(@minus,fApp'*agm_model.M,sum(agm_model.M.^2,1)/2),[],2);                       
    end
    appearance_assign = sparse((1:N)',appearance_assign,ones(N,1),N,K);   
end

