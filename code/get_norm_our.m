function norm = get_norm_our(vecs, norm_type, dim)               
    vecs = abs(vecs); % map all vecs to first quadrant
    if (~isinf(norm_type))
        % p-norm
        norm = (sum(vecs.^norm_type,dim)).^(1/norm_type);
    else
        % Inf norm
        norm = max(vecs,[],dim);
    end    
end