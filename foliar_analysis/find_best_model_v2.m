% 
% Dissimilarity evaluation
%
% Find the best model for samples of a leaf
%
%   img - original image
%
%   leaves - the samples of a damaged leaf
%
%   l_models - models and samples from the build_leaf_models function
%
%   l_crop_size - annotation data of the different sizes of the image
%   during the process of cutting and resizing the image
%
%   l_crop_pad - annotation data of the different padding of the image
%   during the process of cutting and resizing the image
%
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)


function [leaf_model, leaf_damaged_to_model, id_damaged_leaf,...
    model_crop_size, model_crop_pad, sample_row_col] = ...
    find_best_model_v2(leaves, l_models, l_crop_size, l_crop_pad)


qtty_leaves = length(leaves);

[h_models, w_models] = size(l_models);
eval_models = realmax * ones(h_models, w_models, qtty_leaves);
energy = realmax * ones(h_models, w_models); 

for i=1:qtty_leaves
    leaf_defoliated = leaves{i};
    mask_leaf_defoliated = logical(leaf_defoliated(:,:,2));
    mask_leaf_defoliated = imfill(mask_leaf_defoliated,'holes');
    parfor j=1:(h_models*w_models)
        sample = l_models{j};
        
        % the area that are not in the intersection between the sample and the damaged leaf
        sample_mask = logical(sample(:,:,2));
        sample_mask = imfill(sample_mask,'holes');  

        energy(j) = sum(abs(mask_leaf_defoliated(:) - sample_mask(:)));

        
    end
    eval_models(:,:,i) = energy;
end

[e_models, idx_leaf] = min(eval_models, [], 3);
%e_models(:,1) = e_models(:,1) - 0.05;
[~, idx] = min(e_models(:));

[row, col] = ind2sub([h_models, w_models], idx);

sample_row_col = [row, col];

leaf_model = l_models{row,1};
model_crop_size = l_crop_size{row,col};
model_crop_pad = l_crop_pad{row,col};

id_damaged_leaf = idx_leaf(row,col);
leaf_damaged = leaves{id_damaged_leaf};
leaf_damaged_to_model = map_model_to_ref(leaf_damaged, model_crop_size, model_crop_pad);

end



