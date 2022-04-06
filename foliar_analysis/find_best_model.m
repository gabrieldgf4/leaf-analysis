% 
% Dissimilarity evaluation
%
% Find the best model for samples of a leaf
%
%   img - original image
%
%   leaves - the samples of a damaged leaf
%
%   l_models - models and samples from the build_leaf_models function
%
%   l_crop_size - annotation data of the different sizes of the image
%   during the process of cutting and resizing the image
%
%   l_crop_pad - annotation data of the different padding of the image
%   during the process of cutting and resizing the image
%
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% Attention 
% To Run the EMD Distance
% run multilevelOT/initialize.m
% run multilevelOT/src_c/compile_pdhg.m

function [leaf_model, leaf_damaged_to_model, id_damaged_leaf,...
    model_crop_size, model_crop_pad, sample_row_col] = ...
    find_best_model(leaves, l_models, l_crop_size, l_crop_pad)

% prepare to run EMD distance
%h_grid = 9.7656e-04;
p_groud_metric = 2;
opts = [];
opts.tol = 1e-5; % tolerance for fixed-point-residual
opts.verbose = 0; % display metrics
opts.L = 6; % number of Levels

qtty_leaves = length(leaves);

[h_models, w_models] = size(l_models);
eval_models = realmax * ones(h_models, w_models, qtty_leaves);
energy = realmax * ones(h_models, w_models); 
[height, width, ~] = size(leaves{1});


for i=1:qtty_leaves
    leaf_defoliated = leaves{i};
    %mask_leaf_defoliated = leaf_defoliated(:,:,2) > 0;
    mask_leaf_defoliated = logical(leaf_defoliated(:,:,2));
    mask_leaf_defoliated = imfill(mask_leaf_defoliated,'holes');
    parfor j=1:(h_models*w_models)
        sample = l_models{j};
        
        % the area that are not in the intersection between the sample and the damaged leaf
        %sample_mask = sample(:,:,2) > 0;
        sample_mask = logical(sample(:,:,2));
        sample_mask = imfill(sample_mask,'holes');
        sample_mask_outlier = (sample_mask | mask_leaf_defoliated) & ~(sample_mask & mask_leaf_defoliated);
        n = sum(sample_mask_outlier(:)) / (height*width);
        
        % regions that are in the damaged leaf but not in the leaf sample
        z = mask_leaf_defoliated & ~sample_mask;
        z = sum(z(:)) / (height*width);
        
        % regions that are in the leaf sample but not in the damaged leaf
        % adequado quando a perda e pequena
        w = sample_mask & ~mask_leaf_defoliated;
        w = sum(w(:)) / (height*width);

        % only the area of the input damaged leaf
        sample = sample.*mask_leaf_defoliated;
        
        [row, col] = ind2sub([h_models, w_models], j);
        leaf_defoliated_to_model_mask = map_model_to_ref(mask_leaf_defoliated, l_crop_size{j}, l_crop_pad{j});
        model_original = l_models{row,1};
        %model_original_mask = model_original(:,:,2) > 0;
        model_original_mask = logical(model_original(:,:,2));
        model_original_mask = imfill(model_original_mask,'holes');
        % regions that are in the leaf model but not in the damaged leaf
        r = model_original_mask & ~leaf_defoliated_to_model_mask;
        r = sum(r(:)) / (height*width);
        % regions that are in the damaged leaf but not in the leaf model
        t = leaf_defoliated_to_model_mask & ~model_original_mask;
        t = sum(t(:)) / (height*width);
        
        % the EMD metric
        [h_grid,rho0,rho1,x,y] = local_ReadIMG(leaf_defoliated,sample);
        [m, phi] = W1PDHG_ML(h_grid, rho0, rho1, p_groud_metric, opts);
        
        energy(j) = PrimalFunL2(m, h_grid) + n + z + w + r + t;   
%         energy(j) = PrimalFunL2(m, h_grid);   

        
    end
    eval_models(:,:,i) = energy;
end

[e_models, idx_leaf] = min(eval_models, [], 3);
%e_models(:,1) = e_models(:,1) - 0.05;
[~, idx] = min(e_models(:));

[row, col] = ind2sub([h_models, w_models], idx);

sample_row_col = [row, col];

leaf_model = l_models{row,1};
model_crop_size = l_crop_size{row,col};
model_crop_pad = l_crop_pad{row,col};

id_damaged_leaf = idx_leaf(row,col);
leaf_damaged = leaves{id_damaged_leaf};
leaf_damaged_to_model = map_model_to_ref(leaf_damaged, model_crop_size, model_crop_pad);

end


function [h,rho0,rho1,x,y] = local_ReadIMG(img1,img2)
% A function to create a OT problem from two images.
% Author: Jialin Liu (liujl11@math.ucla.edu) Modified: 2018-10-10

img1 = double(img1);
img2 = double(img2);

if size(img1,3)>1, img1 = mean(img1,3); end
if size(img2,3)>1, img2 = mean(img2,3); end

[Mx1, My1] = size(img1);
[Mx2, My2] = size(img2);
M = max([Mx1 My1 Mx2 My2]);

Mpower = ceil(log(M-1)/log(2));
M = 2^Mpower + 1;

h=1/(M-1);
x = 0:h:1;
y = 0:h:1;

% The following operation is to add a zero boundary
% The reason why we do this is:
% In the grid system, if there are 256*256 "squares",
% there are 257*257 nodes.
rho0 = padarray(img1, [M-Mx1, M-My1], 0, 'post');
rho1 = padarray(img2, [M-Mx2, M-My2], 0, 'post');

min1 = min(rho0(:));
min2 = min(rho1(:));
if min1 < 0, rho0 = rho0 - min1; end % must be non-negative
if min2 < 0, rho1 = rho1 - min2; end

rho0 = rho0 / sum(rho0(:));
rho1 = rho1 / sum(rho1(:));
rho0 = rho0 / h / h;
rho1 = rho1 / h / h;

end

