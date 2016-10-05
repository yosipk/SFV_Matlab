function parms = get_imagevecs_parms(parms)

d = 2;
D = parms.feat_dim_proj;
C = str2num(parms.spatial_components);
K = parms.appearance_components;
 
if (strcmp(parms.spatial_model_type,'MULTINOMIAL'))
    parms.imagevec_function = @get_spm;
    if (strcmp(parms.appearance_model_type,'MULTINOMIAL'))
        parms.imagevec_dim = K * C;
    elseif (strcmp(parms.appearance_model_type,'GMM'))
        parms.imagevec_dim = K * C * (1 + 2 * D);
    else
        error('Unknown appearance model type');
    end
elseif (strcmp(parms.spatial_model_type,'GMM'))
    if (parms.learn_spatial_model)
        error('Not refactored yet');
        % sfv_learn
        % asfv_learn
    else
        if (strcmp(parms.appearance_model_type,'MULTINOMIAL'))
            parms.imagevec_function = @get_sfv;
            parms.imagevec_dim = K * (1 + C * (1 + 2 * d));
        elseif (strcmp(parms.appearance_model_type,'GMM'))
            parms.imagevec_function = @get_asfv;
            parms.imagevec_dim = K * (1 + 2 * D + C * (1 + 2 * d));
        else
            error('Unknown appearance model type');
        end
    end
else
    error('Unknown spatial model type');
end