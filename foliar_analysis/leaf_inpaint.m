%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function reconstructed_leaf  = leaf_inpaint(leaf_model, leaf_damaged_to_model)

    leaf_model_mask = logical(leaf_model(:,:,2));
    leaf_model_mask = imfill(leaf_model_mask,'holes');
    leaf_damaged_to_model_mask = logical(leaf_damaged_to_model(:,:,2));

    im = leaf_damaged_to_model;
    immask = im;
  
    mask = double(~leaf_damaged_to_model_mask);
    reconstructed_leaf = inpaintBCT(immask,'orderD',mask,'guidanceC',[26 5550 1 1]);

    cHull = bwconvhull(leaf_damaged_to_model_mask);
    
    mask_final = leaf_model_mask & cHull;
    
    reconstructed_leaf = reconstructed_leaf.*mask_final;
end