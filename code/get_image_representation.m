function image_vector = get_image_representation(position, appearance, parms)

appearance_projected = pca_project(appearance, parms.appearance_subspace, parms.feat_dim_proj);
image_vector = parms.imagevec_function(position, appearance_projected, parms.appearance_model, parms.spatial_model, parms.normalizer);
assert(sum(isnan(image_vector))==0);
assert(sum(isinf(image_vector))==0);