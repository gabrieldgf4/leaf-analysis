%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


% lf = map_model_to_ref(leaf_models{1,4}, leaf_crop_size{1,4}, leaf_crop_pad{1,4});
% lf = map_model_to_ref(leaf_models{100,4}, leaf_crop_size{100,4}, leaf_crop_pad{100,4});

function leaf = map_model_to_ref(leaf_model,leaf_crop_size, leaf_crop_pad)

leaf = imresize(leaf_model, leaf_crop_size, 'nearest', 'Antialiasing', false);

leaf = padarray(leaf, [0, leaf_crop_pad(1)], 'pre');
leaf = padarray(leaf, [0, leaf_crop_pad(2)], 'post');
leaf = padarray(leaf, [leaf_crop_pad(3), 0], 'pre');
leaf = padarray(leaf, [leaf_crop_pad(4), 0], 'post');

end