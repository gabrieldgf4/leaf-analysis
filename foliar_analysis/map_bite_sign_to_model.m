%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function original_bite_sign_to_model = map_bite_sign_to_model(leaf_out, bite_signature, ...
  leaves_back, id_damaged_leaf, model_crop_size, model_crop_pad)

[height, width, ~] = size(leaf_out);

leaf_out_mask = logical(leaf_out(:,:,2));
leaf_out_mask = double(imfill(leaf_out_mask,'holes'));
leaf_out_mask(bite_signature) = 2;

leaf_back = leaves_back(id_damaged_leaf,:);
 
 % rotate the leaf
leaf_rot = imrotate(leaf_out_mask, -leaf_back{3});

[rows, columns] = find(leaf_rot);

% adjust rotated leaf to the same size of the original
leaf_crop = leaf_rot(min(rows):max(rows), min(columns):max(columns), : );

% prepare the output
original_bite_sign_to_model = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);

original_bite_sign_to_model = map_model_to_ref(original_bite_sign_to_model, model_crop_size, model_crop_pad);

original_bite_sign_to_model = (original_bite_sign_to_model == 2);


end