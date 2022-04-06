%
%   img - original image
%
%
%   'filter_size' defines the size of a median filter kernel
%
%   'hough_NumPeaks' specifies the maximum number of peaks to identify
%
%   'hough_Th' Nonnegative scalar.
%               Values of H below 'Threshold' will not be considered
%               to be peaks. Threshold can vary from 0 to Inf.
%
%   'hough_FillGap'   Positive real scalar.
%               When HOUGHLINES finds two line segments associated
%               with the same Hough transform bin that are separated
%               by less than 'FillGap' distance, HOUGHLINES merges
%               them into a single line segment.
%
%   'hough_MinLength' Positive real scalar.
%               Merged line segments shorter than 'MinLength'
%               are discarded.
%
%   theta_range - remove lines from houghlines that are in the same theta range
%
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

% leaves = detect_leaf(img, 3, 1, 10);

function [leaves, leaf_original_back] = detect_leaf(img, filter_size, apply_hough_transform, theta_range)

img = double(img);
[height, width, ~] = size(img);

[leaf,leaf_mask] = leaf_segmentation(img, filter_size);

% find the larger bounding box
% bw = logical(leaf(:,:,2));
% bw = imfill(bw,'holes');
bw = leaf_mask;
bw_l = bwlabel(bw);
info = regionprops(bw_l,'Boundingbox','Area');
[~, idx] = max([info.Area]);

% use only the larger bonding box (i.e., the leaf)
% bw_l(bw_l~=idx) = 0;
% leaf = leaf.*logical(bw_l); 

% crop the leaf      
[rows, columns] = find(bw_l);
leaf = leaf(min(rows):max(rows), min(columns):max(columns), : );
    
% it is used in the map_ref_to_original.m
leaf_back_size1 = [size(leaf,1), size(leaf,2)];
leaf_back_pad1 = [ min(columns)-1,  width-max(columns), min(rows)-1, height-max(rows) ];
    
% rescale the larger bounding box
leaf = imresize(leaf, [height, width], 'nearest', 'Antialiasing', false);

% find the central line of the leaf
ref_line = find_ReferenceLine(leaf);

x1 = ref_line(1); y1 = ref_line(3); x2 = ref_line(2); y2 = ref_line(4);
slope = (y2 - y1) ./ (x2 - x1);
angle = atand(slope);
angle = floor(-angle);
% the central line
central_line = struct('point1', [y1 x1], 'point2', [y2 x2], 'theta', angle, 'rho', 0);

% find lines using Hough Transformation
if apply_hough_transform == 1
    % internal borders only
    e_bordas = bwmorph(leaf(:,:,2),'remove');
    se = strel('disk', 2);
    e_bordas = imdilate(e_bordas, se);
    e = edge(leaf(:,:,2),'sobel');
    e = e & ~(e & e_bordas);
    hough_NunPeaks = 5;
    hough_Th = 0.85;
    hough_FillGap = 5;
    hough_MinLength = 20;
    [H,theta,rho] = hough(e);
    % Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
    P = houghpeaks(H,hough_NunPeaks,'threshold',ceil(hough_Th * max(H(:))));
    % Find lines in the image using the houghlines function.
    lines = houghlines(e,theta,rho,P,'FillGap',hough_FillGap, 'MinLength',hough_MinLength);
    % add the central line to the first row of lines
    lines = [central_line, lines];
else
% add the central line to the first row of lines
lines = central_line;
end

% remove lines that are in the same theta range (theta degree)
distances = dist([lines.theta], 'cityblock');
qtty_lines = length(lines);
val_theta = true(qtty_lines,1);
for k=1:qtty_lines
    if val_theta(k) == 1
        idx = distances(k,:) <= theta_range;
        val_theta(idx) = 0;
        val_theta(k) = 1;
    end
end
lines = lines(val_theta);

% figure, imagesc(uint8(leaf)), hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end

% remove lines with same theta angle
%[~, idx] = unique([lines.theta].', 'rows', 'stable');
%lines = lines(idx);

leaves = cell(length(lines), 1);
leaf_original_back = cell(length(lines), 6);

    % it is used in the map_ref_to_original.m
        [h_tpl, w_tpl, ~] = size(leaf);
        leaf_back_size12 = [h_tpl, w_tpl];
        
for k=1:length(lines)
    % rotate the leaf
    leaf_rot = imrotate(leaf, lines(k).theta);
    
    [h_rot, w_rot, ~] = size(leaf_rot); 
    %bw = leaf_rot(:,:,2) > 0;
    bw = logical(leaf_rot(:,:,2));
    bw = imfill(bw,'holes');
    [rows_ref, columns_ref] = find(bw);
      
    % adjust rotated leaf to the same size of the original
    leaf_crop = leaf_rot(min(rows_ref):max(rows_ref), min(columns_ref):max(columns_ref), : );
   
    % it is used in the map_ref_to_original.m
    leaf_back_size2 = [size(leaf_crop,1), size(leaf_crop,2)];
    leaf_back_pad2 = [min(columns_ref)-1,  w_rot-max(columns_ref), min(rows_ref)-1, h_rot-max(rows_ref)];   
    
    leaf_original_back(k,:) = { leaf_back_size2, leaf_back_pad2,...
        -lines(k).theta, leaf_back_size12, leaf_back_size1, leaf_back_pad1 };
    
    % prepare the output
    leaf_out = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);
    
    leaves(k) = { leaf_out };
end

end