function spatial_model = set_spatial_model(parms)
% final spatial model is an uniform mixture of three spatial models

spatial_models = cell(1,3);
n_spatial_components = [1 4 3];

% 1x1
spatial_models{1}.M =   [ 1/2  1/2]';
spatial_models{1}.Psi = [1/12 1/12]';
spatial_models{1}.mix = 1;
spatial_models{1}.W = zeros(2,0,1);

% 2x2
spatial_models{2}.M =   [ 1/4  1/4;
                          1/4  3/4;
                          3/4  1/4;
                          3/4  3/4]';
spatial_models{2}.Psi = [1/48 1/48;
                         1/48 1/48;
                         1/48 1/48;
                         1/48 1/48]';
spatial_models{2}.mix = [1/4 1/4 1/4 1/4]';
spatial_models{2}.W = zeros(2,0,4);

% 1x3
spatial_models{3}.M =   [ 1/2 1/6;
                          1/2 1/2;
                          1/2 5/6]';
spatial_models{3}.Psi = [1/12 1/108;
                         1/12 1/108;
                         1/12 1/108]';
spatial_models{3}.mix = [1/3 1/3 1/3]';
spatial_models{3}.W = zeros(2,0,3);

% parsing the string
nums_start = [1 strfind(parms.spatial_components,'+')+1];
nums_end = [strfind(parms.spatial_components,'+')-1 length(parms.spatial_components)];

n_models = length(nums_start);

spatial_model.M = [];
spatial_model.Psi = [];
spatial_model.mix = [];
spatial_model.W = [];
spatial_model.quantization = [];

for n = 1:n_models
    model_id = find(n_spatial_components == str2num(parms.spatial_components(nums_start(n):nums_end(n))));
    spatial_model.M = [spatial_model.M spatial_models{model_id}.M];
    spatial_model.Psi = [spatial_model.Psi spatial_models{model_id}.Psi];
    spatial_model.mix = [spatial_model.mix; spatial_models{model_id}.mix];
    spatial_model.W = cat(3,spatial_model.W,spatial_models{model_id}.W);
    spatial_model.quantization = [spatial_model.quantization; n*ones(size(spatial_models{model_id}.mix))];
end
spatial_model.mix = spatial_model.mix / sum(spatial_model.mix);