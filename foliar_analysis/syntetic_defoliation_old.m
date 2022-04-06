 % Perform a syntetic defoliation into an image
%
%
%   img - the input leaf
%
%   'filter_size' defines the size of a median filter kernel
%
%   'caterpillar_bite' - path for the insect bites image dataset
%
%   min_defoliation - the minimum defoliation that is accepted
%
%   max_defoliation - the maximum defoliation that is accepted
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% [leaf_out, bite_signature, img_out, leaf_seg, defoliation_level] = syntetic_defoliation_old(img, 5, 'caterpillar_bite', 5, 30);

function [leaf_out, bite_signature, img_out, leaf_seg, defoliation_level] = ...
    syntetic_defoliation_old(img, filter_size, path_bites, min_defoliation, max_defoliation)

rng shuffle; % creates a different seed each time

if min_defoliation > max_defoliation
    error('min_defoliation must be lower than max_defoliation');
end

if exist('bites', 'var') == 0
    bites = load_images(path_bites, 'png');
end

if max_defoliation >= 100
    max_defoliation = 99;
end

if min_defoliation <= 0 
    min_defoliation = 1;
end

[height, width, ~] = size(img);

% leaf_seg = leaf_segmentation(img, filter_size);
% mask_background = leaf_seg(:,:,2) == 0;
[leaf_seg, leaf_mask] = leaf_segmentation(img, filter_size);
mask_background = ~leaf_mask;

% bw_leaf2 = leaf_seg(:,:,2) > 0;
% mask_leaf_after = bw_leaf2;
bw_leaf2 = leaf_mask;
mask_leaf_after = bw_leaf2;

defoliation_level = 0;

[height_bite, ~] = size(bites{1});
min_size  = round(height_bite/2);
max_size = round((height_bite/2)+(height*0.3));

% while condition: first part avoids 0% of defoliiation, second part
% avoids a defoliation level lower than min_defoliation and third part
% avoids a defoliation level higher than max_defoliation
% i.e., min_defoliation <= defoliation_level <= max_defoliation

while (defoliation_level < min_defoliation) || (defoliation_level > max_defoliation)
    if defoliation_level < min_defoliation
        % increase the bite
        max_size = round(max_size*1.1);
        min_size = round(min_size*1.1);
        if max_size > height
            min_size  = round(height_bite/2);
            max_size = round((height_bite/2)+(height*0.3));
        end
        [mask_leaf_after, mask_leaf_before, defoliation_level] = defoliation(mask_leaf_after, bites, min_size, max_size, height, width, bw_leaf2);
    else
        % decrease the bite
        max_size = round(max_size*0.9);
        min_size = round(min_size*0.9);
        if min_size < height
            min_size  = round(height_bite/2);
            max_size = round((height_bite/2)+(height*0.3));
        end
        [mask_leaf_after, mask_leaf_before, defoliation_level] = defoliation(mask_leaf_before, bites, min_size, max_size, height, width, bw_leaf2);
    end 
end

mask_leaf3 = mask_leaf_after | mask_background;

leaf_out = double(img).*mask_leaf_after;
img_out = double(img).*mask_leaf3;

e = edge(bw_leaf2,'sobel');
e2 = edge(mask_leaf_after,'sobel');
bite_signature = e2 & ~e;

end


function [mask_leaf_after, mask_leaf_before, defoliation_level] = defoliation(mask_leaf, bites, min_size, max_size, height, width, bw_leaf2)

    mask_leaf_before = mask_leaf;
    
    qtty_bites = length(bites);
    % select a number of bites to be used
    n_bites = randi([1, qtty_bites]);
    
    for i=1:n_bites
        % select a bite
        bite = bites{ randi([1, qtty_bites]) };

        % rotate the bite
        angle_rot = randi([0, 360]);
        bite = imrotate(bite, angle_rot);
        % crop the bite
        [rw, cl] = find(bite);
        bite = bite(min(rw):max(rw), min(cl):max(cl));
        
        % resize the bite with aspect ratio preserved
        rand_scale = randi([min_size, max_size]);
        bite = imresize(bite, [rand_scale, NaN] );
        
        % perform the bite in the input image
        [h_bite, w_bite] = size(bite);
        % crop the leaf      
        [rows, columns] = find(mask_leaf);
        h_top = randi([min(rows), max(rows)]);
        h_buttom = h_top + h_bite -1;
        if h_buttom > height
            bite = bite(1:height-h_top+1, :);
            h_buttom = height;
        end
        w_left = randi([min(columns), max(columns)]);
        w_right = w_left + w_bite -1;
        if w_right > width
            bite = bite(:, 1:width-w_left+1);
            w_right = width;
        end

        intersection = mask_leaf(h_top:h_buttom, w_left:w_right) & bite;
        mask_leaf(h_top:h_buttom, w_left:w_right) = mask_leaf(h_top:h_buttom, w_left:w_right) - intersection;
    end
% close holes if they exist
mask_leaf = imfill(mask_leaf, 'holes');

% find the larger bounding box
bw_l = bwlabel(mask_leaf);
info = regionprops(bw_l,'Boundingbox','Area');
[~, idx] = max([info.Area]);

% use only the larger bonding box (i.e., the leaf)
bw_l(bw_l~=idx) = 0;
mask_leaf = mask_leaf.*logical(bw_l); 


defoliation_level = 100 - ( ( sum(mask_leaf(:)) / sum(bw_leaf2(:)) ) .* 100 );

mask_leaf_after = mask_leaf;


end

