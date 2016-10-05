function image_vectors = power_normalization(parms, normalization_parm_val)
    assert(~isempty(normalization_parm_val));
    signs = 2*(parms.image_vectors>0)-1;
    image_vectors = ((parms.image_vectors .* signs).^normalization_parm_val) .* signs;    
end