% leaf_segmentation segments the leaf from the background. 
%
%   'I' original image
%
%   'filter_size' defines the size of a median filter kernel
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% leaf = leaf_segmentation(I, 11);
% leaf = leaf_segmentation(I, 5);

function [leaf,bw_green] = leaf_segmentation(I, filter_size)

I = double(I);
%I = im2double(I);

% exceds the green channel
r = I(:,:,1); g = I(:,:,2); b = I(:,:,3);

% median filter
r = colfilt(r, [filter_size filter_size], 'sliding', @median);
g = colfilt(g, [filter_size filter_size], 'sliding', @median);
b = colfilt(b, [filter_size filter_size], 'sliding', @median);

% it is equivalent to colfilt
% r = medfilt2(r, [filter_size, filter_size]);
% g = medfilt2(g, [filter_size, filter_size]);
% b = medfilt2(b, [filter_size, filter_size]);

% mean filter
% r = conv2(r, [filter_size, filter_size],'same');
% g = conv2(g, [filter_size, filter_size],'same');
% b = conv2(b, [filter_size, filter_size],'same');

green = double(2*g-r-b);

% binarize image using otsu method
only_g = green; %green(green > 0); % ignore zeros
max_green = max(green(:));
[counts,~] = imhist(only_g/max_green);
T = otsuthresh(counts(1:end));
bw_green = imbinarize(green, T); %(green/max_green > T);

bw_green = imfill(bw_green, 'holes');

leaf = I.*bw_green;

end