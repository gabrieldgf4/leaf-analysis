%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function reconstructed_leaf  = leaf_blending(leaf_model, leaf_damaged_to_model)

    leaf_model_mask = logical(leaf_model(:,:,2));
    leaf_model_mask = imfill(leaf_model_mask,'holes');
    leaf_damaged_to_model_mask = logical(leaf_damaged_to_model(:,:,2));
    
    cHull = bwconvhull(leaf_damaged_to_model_mask);

    source_mask = leaf_model_mask & leaf_damaged_to_model_mask;
    source = leaf_damaged_to_model.*source_mask;
    target_mask = leaf_model_mask & cHull;
    target = leaf_model.*target_mask;
    reconstructed_leaf = ConvPyrBlending(target,source,source_mask, target_mask);

end