%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

% outputs
%
% templates_crop_data     holds the number of columns and rows that were removed
%                   after the cropping operation.
%                   from left to rigth
%                   [emptyCol_lr, emptyCol_rl, emptyCol_td, emptyCol_dt]

function [templates] = prepare_template_defoliation(leaf, theta)

[height, width, ~] = size(leaf);

% rotate leaf
leaf_rot = imrotate(leaf, theta);
% binarize leaf_rot
%bw = leaf_rot(:,:,2) > 0;
bw = logical(leaf_rot(:,:,2));
bw = imfill(bw,'holes');

% Find the region of the leaf in the image
[rows, columns] = find(bw);

% the width of the leaf
left_col = min(columns);
right_col = max(columns);
w_box = right_col - left_col;
% defoliation on left and right sides
half_w_box = floor(w_box / 2);
if mod(half_w_box,2) ~= 0
    half_w_box = half_w_box + 1;
end

% template with no defoliation
tpl1 = bw;
tpl1 = rot_template(leaf, tpl1, -theta);
tpl1 = imresize(tpl1, [height, width], 'nearest', 'Antialiasing', false);

% 25% defoliation in the left side
tpl2 = bw;
tpl2(:, left_col:(left_col+(half_w_box/2))) = 0;
tpl2 = rot_template(leaf, tpl2, -theta);
tpl2 = imresize(tpl2, [height, width], 'nearest', 'Antialiasing', false);
% 50% defoliation in the left side
tpl3 = bw;
tpl3(:, left_col:(left_col+(half_w_box))) = 0;
tpl3 = rot_template(leaf, tpl3, -theta);
tpl3 = imresize(tpl3, [height, width], 'nearest', 'Antialiasing', false);
% 75% defoliation in the left side
tpl4 = bw;
tpl4(:, left_col:(left_col+(half_w_box * 1.5))) = 0;
tpl4 = rot_template(leaf, tpl4, -theta);
tpl4 = imresize(tpl4, [height, width], 'nearest', 'Antialiasing', false);


% 25% defoliation in the rigth side
tpl5 = bw;
tpl5(:, right_col:-1:(right_col-(half_w_box/2))) = 0;
tpl5 = rot_template(leaf, tpl5, -theta);
tpl5 = imresize(tpl5, [height, width], 'nearest', 'Antialiasing', false);
% 50% defoliation in the rigth side
tpl6 = bw;
tpl6(:, right_col:-1:(right_col-(half_w_box))) = 0;
tpl6 = rot_template(leaf, tpl6, -theta);
tpl6 = imresize(tpl6, [height, width], 'nearest', 'Antialiasing', false);
% 75% defoliation in the rigth side
tpl7 = bw;
tpl7(:, right_col:-1:(right_col-(half_w_box * 1.5))) = 0;
tpl7 = rot_template(leaf, tpl7, -theta);
tpl7 = imresize(tpl7, [height, width], 'nearest', 'Antialiasing', false);


% the height of the leaf
top_line = min(rows);
bottom_line = max(rows);
h_box = bottom_line - top_line;
% defoliation on top and bottom sides
half_h_box = floor(h_box / 2);
if mod(half_h_box,2) ~= 0
    half_h_box = half_h_box + 1;
end

% 25% defoliation in the top side
tpl8 = bw;
tpl8(top_line:(top_line+(half_h_box/2)), :) = 0;
tpl8 = rot_template(leaf, tpl8, -theta);
tpl8 = imresize(tpl8, [height, width], 'nearest', 'Antialiasing', false);
% 50% defoliation in the top side
tpl9 = bw;
tpl9(top_line:(top_line+(half_h_box)), :) = 0;
tpl9 = rot_template(leaf, tpl9, -theta);
tpl9 = imresize(tpl9, [height, width], 'nearest', 'Antialiasing', false);
% 75% defoliation in the top side
tpl10 = bw;
tpl10(top_line:(top_line+(half_h_box * 1.5)), :) = 0;
tpl10 = rot_template(leaf, tpl10, -theta);
tpl10 = imresize(tpl10, [height, width], 'nearest', 'Antialiasing', false);

% 25% defoliation in the bottom side
tpl11 = bw;
tpl11(bottom_line:-1:(bottom_line-(half_h_box/2)), :) = 0;
tpl11 = rot_template(leaf, tpl11, -theta);
tpl11 = imresize(tpl11, [height, width], 'nearest', 'Antialiasing', false);
% 50% defoliation in the bottom side
tpl12 = bw;
tpl12(bottom_line:-1:(bottom_line-(half_h_box)), :) = 0;
tpl12 = rot_template(leaf, tpl12, -theta);
tpl12 = imresize(tpl12, [height, width], 'nearest', 'Antialiasing', false);
% 75% defoliation in the bottom side
tpl13 = bw;
tpl13(bottom_line:-1:(bottom_line-(half_h_box * 1.5)), :) = 0;
tpl13 = rot_template(leaf, tpl13, -theta);
tpl13 = imresize(tpl13, [height, width], 'nearest', 'Antialiasing', false);


% 25% defoliation in the left and right sides
tpl14 = bw;
tpl14(:, left_col:(left_col+(half_w_box/2))) = 0;
tpl14(:, right_col:-1:(right_col-(half_w_box/2))) = 0;
tpl14 = rot_template(leaf, tpl14, -theta);
tpl14 = imresize(tpl14, [height, width], 'nearest', 'Antialiasing', false);


% 25% defoliation in top and bottom sides
tpl15 = bw;
tpl15(top_line:(top_line+(half_h_box/2)), :) = 0;
tpl15(bottom_line:-1:(bottom_line-(half_h_box/2)), :) = 0;
tpl15 = rot_template(leaf, tpl15, -theta);
tpl15 = imresize(tpl15, [height, width], 'nearest', 'Antialiasing', false);



templates = {tpl1, tpl2, tpl3, tpl4, tpl5, tpl6, tpl7, tpl8, ...
    tpl9, tpl10, tpl11, tpl12, tpl13, tpl14, tpl15};

end

function tpl = rot_template(leaf, tpl, theta)

[height, width, ~] = size(leaf);

tpl = imrotate(tpl, theta);
[height_rot, width_rot] = size(tpl);

lines_to_remove = floor((height_rot - height) / 2);
up_down = lines_to_remove;
bottom_up = (height_rot - lines_to_remove) - lines_to_remove +1;
tpl(1:up_down,:,:) = [];
tpl(end:-1:bottom_up,:,:) = [];

columns_to_remove = floor((width_rot - width) / 2);
left_right = columns_to_remove;
right_left = (width_rot - columns_to_remove) - columns_to_remove +1;
tpl(:, 1:left_right,:) = [];
tpl(:, end:-1:right_left,:) = [];


end