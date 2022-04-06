%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function reconstructed_leaf  = leaf_reconstruction(leaf_model, leaf_damaged_to_model)

    leaf_damaged_to_model_mask = logical(leaf_damaged_to_model(:,:,2));
    
    cHull = bwconvhull(leaf_damaged_to_model_mask);

    reconstructed_leaf = leaf_model.*cHull;

end