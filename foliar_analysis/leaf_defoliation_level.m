%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function [leaf_loss_mask, defoliation_level] = leaf_defoliation_level(leaf_model, leaf_damaged_to_model)

[~,~,c1] = size(leaf_model);
[~,~,c2] = size(leaf_damaged_to_model);

if c1==3
    leaf_model_mask = logical(leaf_model(:,:,2));
else
    leaf_model_mask = logical(leaf_model);
end  

leaf_model_mask = imfill(leaf_model_mask,'holes');
    
if c2==3
    leaf_damaged_to_model_mask = logical(leaf_damaged_to_model(:,:,2));
else
    leaf_damaged_to_model_mask = logical(leaf_damaged_to_model);
end
    
    % area of the leaf model that is not in the damaged leaf
    leaf_loss_mask = leaf_model_mask & ~leaf_damaged_to_model_mask;
    
    defoliation_level = abs(( ( sum(leaf_loss_mask(:)) / sum(leaf_model_mask(:)) ) .* 100 ));

end