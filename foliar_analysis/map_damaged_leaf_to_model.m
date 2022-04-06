%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function [leaf_labeled_to_model, defoliation_level] = map_damaged_leaf_to_model(leaf_seg, leaf_out,...
  leaves_back, id_damaged_leaf)

[height, width, ~] = size(leaf_seg);

leaf_seg_mask = logical(leaf_seg(:,:,2));
leaf_seg_mask = imfill(leaf_seg_mask,'holes');
leaf_out_mask = logical(leaf_out(:,:,2));
leaf_out_mask = imfill(leaf_out_mask,'holes');

leaf_preserved = leaf_seg_mask & leaf_out_mask;
leaf_loss = leaf_seg_mask & ~leaf_out_mask;

leaf_labeled = double(leaf_seg_mask);
leaf_labeled(leaf_preserved) = 1;
leaf_labeled(leaf_loss) = 2;

leaf_back = leaves_back(id_damaged_leaf,:);
 
 % rotate the leaf
leaf_rot = imrotate(leaf_labeled, -leaf_back{3});

%bw = leaf_rot(:,:,1) > 0;
bw = logical(leaf_rot(:,:,1));
bw = imfill(bw,'holes');
[rows, columns] = find(bw);

% adjust rotated leaf to the same size of the original
leaf_crop = leaf_rot(min(rows):max(rows), min(columns):max(columns), : );

% prepare the output
leaf_labeled_to_model = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);

mask_leaf = (leaf_labeled_to_model == 1);
%bw_leaf = leaf_labeled_to_model(:,:,1) > 0;
bw_leaf = logical(leaf_labeled_to_model(:,:,1));
bw_leaf = imfill(bw_leaf,'holes');

defoliation_level = 100 - ( ( sum(mask_leaf(:)) / sum(bw_leaf(:)) ) .* 100 );

end