function image_vectors = multiplicative_normalization(parms, ~)
    assert(~isempty(parms.normalizer.multiplicative));
    image_vectors = bsxfun(@times, parms.image_vectors, parms.normalizer.multiplicative);
end