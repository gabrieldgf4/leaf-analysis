% leaf_templates 
%
%   'images' original images
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
%   'all_lines' a flag 1 that indicates that all lines will be considered
%               including the boundaries lines. A flag 0 to ignore the
%               boundaries lines
%
%   leaves_rot_180 - if '1'rotate the leaf models in 180 degrees and add
%                    them to the models
%
%   idx_templates - indicates the number of the templates to be used, from
%
%   theta_range - remove lines from houghlines that are in the same theta range
%
%   hough_transform - it indicates if the hough trasnform is required
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back] = build_leaf_models_ALL(images, 3, 5, 0.85, 5, 5, 0, 0, [1,14,15], 10, 1);

function [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg] = ...
    build_leaf_models_ALL(images, filter_size, hough_NunPeaks, hough_Th,...
    hough_FillGap, hough_MinLength, all_lines, leaves_rot_180, idx_templates,...
    theta_range, hough_transform)

nfiles = length(images);

leaf_models = cell(nfiles,1);
leaf_crop_size = cell(nfiles,1);
leaf_crop_pad = cell(nfiles,1);
leaf_original_back = cell(nfiles,1);
leaf_original_and_seg = cell(nfiles,1);

for i=1:nfiles
   leaf = leaf_segmentation(images{i}, filter_size);
   [l_models, l_crop_size, l_crop_pad, l_original_back, l_original_and_seg] = ...
       build_leaf_models(images{i}, leaf, hough_NunPeaks, hough_Th, ...
       hough_FillGap, hough_MinLength, all_lines, leaves_rot_180, idx_templates,...
       theta_range, hough_transform);
    leaf_models(i,1) = { l_models };
    leaf_crop_size(i,1) = { l_crop_size };
    leaf_crop_pad(i,1) = { l_crop_pad };
    leaf_original_back(i,1) = { l_original_back };
    leaf_original_and_seg(i,1) = { l_original_and_seg };
end

% take the values of the nested cells
leaf_models = vertcat(leaf_models{:});
leaf_crop_size = vertcat(leaf_crop_size{:});
leaf_crop_pad = vertcat(leaf_crop_pad{:});
leaf_original_back = vertcat(leaf_original_back{:});
leaf_original_and_seg = vertcat(leaf_original_and_seg{:});

end



