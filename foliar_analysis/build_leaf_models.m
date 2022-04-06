% leaf_adjustment find the central line of the leaf and rotate the leaf to
% be aligned in 90 degrees. It uses Hough Transformation and rotation.
%
%   'leaf' a segmented leaf
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
%   'all_lines' a flag 1 that indicates that all lines will be considered
%               including the boundaries lines. A flag 0 to ignore the
%               boundaries lines
%
%   leaves_rot_180 - if '1'rotate the leaf models in 180 degrees and add
%                    them to the models
%
%   idx_templates - indicates the number of the templates to be used, from
%                   1 to 15
%
%   theta_range - remove lines from houghlines that are in the same theta range
%
%   hough_transform - it indicates if the hough trasnform is required
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)               

% [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg] = build_leaf_models(I, leaf, 5, 0.85, 5, 20, 0, [1,14,15], 10, 1);

function [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg]...
    = build_leaf_models(I, leaf, hough_NunPeaks, hough_Th, hough_FillGap,...
    hough_MinLength, all_lines, leaves_rot_180, idx_templates, theta_range, hough_transform)

leaf = double(leaf);
leaf_original = leaf;

[height, width, ~] = size(leaf_original);

% find the larger bounding box
bw = logical(leaf(:,:,2));
bw = imfill(bw,'holes');
bw_l = bwlabel(bw);
info = regionprops(bw_l,'Boundingbox','Area');
[~, idx] = max([info.Area]);

% use only the larger bonding box (i.e., the leaf)
%boxes = floor(boxes);
bw_l(bw_l~=idx) = 0;
leaf = leaf.*logical(bw_l); 

% crop the leaf
[rows, columns] = find(bw_l);
leaf = leaf(min(rows):max(rows), min(columns):max(columns), : );

% it is used in the map_ref_to_original.m
leaf_back_size1 = [size(leaf,1), size(leaf,2)];
leaf_back_pad1 = [ min(columns)-1,  width-max(columns), min(rows)-1, height-max(rows) ];

% rescale the larger bounding box
leaf = imresize(leaf, [height, width], 'nearest', 'Antialiasing', false);


if all_lines
    e = edge(leaf(:,:,2),'sobel');
else
    % internal borders only
    e_bordas = bwmorph(leaf(:,:,2),'remove');
    se = strel('disk', 2);
    e_bordas = imdilate(e_bordas, se);
    e = edge(leaf(:,:,2),'sobel');
    e = e & ~(e & e_bordas);
end

% find the central line of the leaf
ref_line = find_ReferenceLine(leaf);
% show the central line
% e_bordas = bwmorph(leaf(:,:,2),'remove');
% e_bordas = insertShape(double(e_bordas),'line', [ ref_line(3), ref_line(1), ref_line(4), ref_line(2) ]);
% figure; imshow(e_bordas); 

x1 = ref_line(1); y1 = ref_line(3); x2 = ref_line(2); y2 = ref_line(4);
slope = (y2 - y1) ./ (x2 - x1);
angle = atand(slope);
angle = floor(-angle);
% the central line
central_line = struct('point1', [y1 x1], 'point2', [y2 x2], 'theta', angle, 'rho', 0);

if hough_transform
    % find lines using Hough Transformation
    [H,theta,rho] = hough(e);
    % Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
    P = houghpeaks(H,hough_NunPeaks,'threshold',ceil(hough_Th * max(H(:))));
    % Find lines in the image using the houghlines function.
    lines = houghlines(e,theta,rho,P,'FillGap',hough_FillGap, 'MinLength',hough_MinLength);

    % add the central line to the first row of lines
    lines = [central_line, lines];

    % figure, imshow(uint8(leaf)), hold on
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
else
    lines = central_line;
end

% remove lines that are in the same theta range
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


% a line without rotation
% original_line = struct('point1', [y1 x1], 'point2', [y2 x2], 'theta', 0, 'rho', 0);
% add the original line to the last row of lines
% lines = [lines, original_line];

% remove lines with same theta angle
%[~, idx] = unique([lines.theta].', 'rows', 'stable');
%lines = lines(idx);

% add lines in 180 degrees
if leaves_rot_180
    prior = length(lines);
    lines = [lines, lines];
    for k=prior+1:length(lines)
        lines(k).theta = -180 + lines(k).theta;
    end
end


% prepare templates of defoliation
templates = prepare_template_defoliation(leaf, central_line(1).theta);
templates = templates(idx_templates);

numberTemplates = length(templates);
qttyLines = length(lines);

leaf_models = cell(qttyLines, numberTemplates);
leaf_crop_size = cell(qttyLines, numberTemplates);
leaf_crop_pad = cell(qttyLines, numberTemplates);
leaf_original_back = cell(qttyLines, 6);
leaf_original_and_seg = cell(qttyLines, 2);

%leaf_rotation_theta = { lines(:).theta };
% inverse theta
%leaf_rotation_theta = cellfun( @(leaf_rotation_theta) {leaf_rotation_theta*(-1)}, leaf_rotation_theta);

for i=1:qttyLines

    [l_models, l_crop_size, l_crop_pad, leaf_back_size2, leaf_back_pad2,...
        leaf_back_size12] = rotate_image(leaf, templates, lines(i).theta);
    leaf_models(i,:) = l_models;
    leaf_crop_size(i,:) = l_crop_size;
    leaf_crop_pad(i,:) = l_crop_pad;
    leaf_original_back(i,:) = { leaf_back_size2, leaf_back_pad2,...
        -lines(i).theta, leaf_back_size12, leaf_back_size1, leaf_back_pad1 };
    
    leaf_original_and_seg(i,:) = { double(I), leaf_original };
end

end


function [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_back_size2,...
    leaf_back_pad2, leaf_back_size12] = rotate_image(leaf, templates, theta2)

[height, width, ~] = size(leaf);

% a transform suitable for images
Rimage=[ ...
    cosd(theta2) -sind(theta2) 0
    sind(theta2) cosd(theta2) 0
    0 0 1
    ];
% make tform object suitable for imwarp
tform = affine2d(Rimage);

numberTemplates = length(templates);

leaf_models = cell(1, numberTemplates);
leaf_crop_size = cell(1, numberTemplates);
leaf_crop_pad = cell(1, numberTemplates);

for k=1:numberTemplates
    
    tpl = templates{k};
    lf = leaf.*tpl;

    % transform image and spatial referencing with tform
    [leaf_rot, ~] = imwarp(lf, tform); 
    
     if k == 1
        [h_rot, w_rot, ~] = size(leaf_rot); 
        bw = leaf_rot(:,:,2) > 0;
        [rows_ref, columns_ref] = find(bw);
        leaf_crop = leaf_rot(min(rows_ref):max(rows_ref), min(columns_ref):max(columns_ref), : );
       
        % it is used in the map_model_to_ref.m
        leaf_crop_pad(k) = { [0, 0, 0, 0] };
        leaf_crop_size(k) = { [height, width] }; 
        
        % it is used in the map_ref_to_original.m
        [h_tpl, w_tpl, ~] = size(lf);
        leaf_back_size12 = [h_tpl, w_tpl];
        leaf_back_size2 = [size(leaf_crop,1), size(leaf_crop,2)]; 
        leaf_back_pad2 = [ min(columns_ref)-1,  w_rot-max(columns_ref), min(rows_ref)-1, h_rot-max(rows_ref) ];
        
        % prepare the model
        l_model = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);
     else
        % adjust rotated leaf to the same size of the original
        leaf_crop = leaf_rot(min(rows_ref):max(rows_ref), min(columns_ref):max(columns_ref), : );
        leaf_crop = imresize(leaf_crop, [height, width], 'nearest', 'Antialiasing', false);
        bw = leaf_crop(:,:,2) > 0;
        [rw, cl] = find(bw);
        [he, wi] = size(bw);
        
        % it is used in the map_model_to_ref.m
        % add the padding columns and rows
        leaf_crop_pad(k) = { [min(cl) - 1, wi-max(cl), min(rw) - 1, he-max(rw)] }; 
        % take the size of the portion of leaf and keep them
        leaf_crop2 = leaf_crop(min(rw):max(rw), min(cl):max(cl), : );
        [h, w, ~] = size(leaf_crop2);
        leaf_crop_size(k) = { [h, w] }; 
        
        % prepare the model
        l_model = imresize(leaf_crop2, [height, width], 'nearest', 'Antialiasing', false);
    end       
    
    leaf_models(k) = { l_model };   
end

end

