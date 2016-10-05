function image_vectors = metric_normalization(parms, normalization_parm_val)
    image_vectors = normalize_our(parms.image_vectors, normalization_parm_val, 1);
end