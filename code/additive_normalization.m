function image_vectors = additive_normalization(parms, ~)
    assert(~isempty(parms.normalizer.additive));
    image_vectors = bsxfun(@plus, parms.image_vectors, parms.normalizer.additive);
end