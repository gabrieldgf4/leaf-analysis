%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%


function healthy_leaf_to_model = map_healthy_seg_leaf_to_model(leaf_seg, ...
  leaves_back, id_damaged_leaf)


[height, width, ~] = size(leaf_seg);

leaf_back = leaves_back(id_damaged_leaf,:);
 
 % rotate the leaf
leaf_rot = imrotate(leaf_seg, -leaf_back{3});

bw = logical(leaf_rot(:,:,2));
bw = imfill(bw,'holes');
[rows, columns] = find(bw);

% adjust rotated leaf to the same size of the original
leaf_crop = leaf_rot(min(rows):max(rows), min(columns):max(columns), : );

% prepare the output
healthy_leaf_to_model = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);


end