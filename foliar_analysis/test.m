%
% % Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2022)
%

addpath(genpath('multilevelOT'));
addpath(genpath('DeBleeding'));
addpath(genpath('inpaintBCT'));
addpath(genpath('Evaluation'));
addpath(genpath('utils'));

clear; close all;

%% Load images
modeling_data = load_images('images/modeling_data', 'JPG');
test_data = load_images('images/test_data', 'JPG');

%% Apply synthetic defoliation
img = test_data{1};
filter_size = 5;
[defoliated_leaf_testData, bite_signature_testData, img_out, leaf_seg, defoliation_level_original] = ...
    syntetic_defoliation(img,filter_size,'caterpillar_bite', 15, 30, 30, 50, 1);
figure; imagesc(img);
title('Original Image');
figure; imagesc(uint8(leaf_seg));
title('Original Image after segmentation');
figure; imagesc(uint8(defoliated_leaf_testData)); colormap gray
title(['Synthetic defoliation: ', num2str(defoliation_level_original), '% damage']);

%% Detect features (lines) of the test data
% % apply hougth transform: yes
filter_size = 5;
apply_hough_transform = 1;
theta_range = 10;
[leaves, leaves_back] = detect_leaf(defoliated_leaf_testData, filter_size, apply_hough_transform, theta_range);

% % apply hougth transform: no
% filter_size = 5;
% apply_hough_transform = 0;
% theta_range = 10;
% [leaves, leaves_back] = detect_leaf(defoliated_leaf_testData, filter_size, apply_hough_transform, theta_range);

%% Detect features (lines) of the modeling data and prepare the leaf models
% % apply hougth transform: yes
% % different templantes for each leaf model: no
apply_hough_transform = 1;
templates_number = 1; % only the original position
[leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg] = ...
    build_leaf_models_ALL(modeling_data, filter_size, 5, 0.85, 5, 20, 0, 0, templates_number,...
    theta_range, apply_hough_transform);

% % apply hougth transform: yes
% % different templantes for each leaf model: yes
% apply_hough_transform = 1;
% templates_number = [1,3,6,9,12,14,15]; % different positions
% [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg] = ...
%     build_leaf_models_ALL(modeling_data, filter_size, 5, 0.85, 5, 20, 0, 0, templates_number,...
%     theta_range, apply_hough_transform);

% % apply hougth transform: no
% % different templantes for each leaf model: no
% apply_hough_transform = 0;
% templates_number = 1; % only the original position
% [leaf_models, leaf_crop_size, leaf_crop_pad, leaf_original_back, leaf_original_and_seg] = ...
%     build_leaf_models_ALL(modeling_data, filter_size, 5, 0.85, 5, 20, 0, 0, templates_number,...
%     theta_range, apply_hough_transform);

%% Compare the test data (query image) with the leaf models
% % distance metric: EMD (Earth mover's distance)
[leaf_model, leaf_damaged_to_model, id_damaged_leaf, model_crop_size, model_crop_pad, sample_row_col] =...
    find_best_model(leaves,leaf_models, leaf_crop_size,leaf_crop_pad);

% % distance metric: L1 distance
% [leaf_model, leaf_damaged_to_model, id_damaged_leaf, model_crop_size, model_crop_pad, sample_row_col] =...
%     find_best_model_v2(leaves,leaf_models, leaf_crop_size,leaf_crop_pad);

%% Show the results
[leaf_loss_mask, defoliation_level2] = leaf_defoliation_level(leaf_model, leaf_damaged_to_model);
bite_sign = leaf_bite_signature(leaf_model, leaf_damaged_to_model, 25, 2, 0.99);
reconstructed_leaf_1  = leaf_inpaint(leaf_model, leaf_damaged_to_model);

figure; imshowpair(uint8(leaf_model), uint8(leaf_damaged_to_model))
title('Leaf model and Damaged leaf');

figure; imshowpair(uint8(leaf_model), uint8(bite_sign))
title('Leaf model and Bite segments');

B = imoverlay(uint8(leaf_damaged_to_model), leaf_loss_mask, 'r');
figure; imshow(uint8(B));
title('Damaged areas');

figure; imshow(uint8(reconstructed_leaf_1));
title('Reconstructed Leaf with Inpaint');

%%
%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%

%% Defoliation level evaluation
[leaf_loss_mask, defoliation_level3] = leaf_defoliation_level(leaf_model, leaf_damaged_to_model);
%  for evaluation of the defoliation level in the model space
leaf_seg2 = leaf_segmentation(img,5);
[leaf_labeled_to_model, defoliation_level_model_space] = map_damaged_leaf_to_model(leaf_seg2,...
    defoliated_leaf_testData, leaves_back, id_damaged_leaf);  
defoliation_level_estimated = defoliation_level_model_space;

fprintf('Original defoliation: %2.4f\nEstimated defoliation: %2.4f \n',...
    defoliation_level_original, defoliation_level_estimated)

%% Bite signature evaluation
remove_small_bites = 25; 
size_disc_element = 2;
ecc_thresh = 0.98;
bite_sign = leaf_bite_signature(leaf_model, leaf_damaged_to_model,...
    remove_small_bites, size_disc_element, ecc_thresh);
original_bite_sign_to_model = map_bite_sign_to_model(...
    defoliated_leaf_testData, bite_signature_testData,...
    leaves_back, id_damaged_leaf, model_crop_size, model_crop_pad);
[result_TP_FP_FN] = leaf_evaluation_bites(bite_sign, original_bite_sign_to_model,...
    5, 12, 0.5);

fprintf('True positive bites: %i\nFalse positive bites: %i\nFalse negative bites: %i\n',...
    result_TP_FP_FN(1), result_TP_FP_FN(2), result_TP_FP_FN(3))

%% Leaf reconstruction evaluation
% Leaf reconstruction using the retrived model
healthy_leaf_to_model = map_healthy_leaf_to_model(leaf_seg, filter_size, leaves_back, id_damaged_leaf);
reconstructed_leaf_1  = leaf_reconstruction(leaf_model, leaf_damaged_to_model);
[resultQuality_1, resultDistances_1] = leaf_evaluation_quality(healthy_leaf_to_model, reconstructed_leaf_1);
SSIM_reconstruction_1 = resultQuality_1(1);

figure; imshowpair(uint8(healthy_leaf_to_model), uint8(reconstructed_leaf_1), 'montage')
title('Health leaf and reconstructed with the retrieved model')

fprintf('SSIM model: %1.4f\n', SSIM_reconstruction_1);

%% Leaf reconstruction evaluation
% Leaf reconstruction using image blending
healthy_leaf_to_model = map_healthy_leaf_to_model(leaf_seg, filter_size, leaves_back, id_damaged_leaf);
reconstructed_leaf_2  = leaf_blending(leaf_model, leaf_damaged_to_model);
[resultQuality_2, resultDistances_2] = leaf_evaluation_quality(healthy_leaf_to_model, reconstructed_leaf_2);
SSIM_reconstruction_2 = resultQuality_2(1);

figure; imshowpair(uint8(healthy_leaf_to_model), uint8(reconstructed_leaf_2), 'montage')
title('Health leaf and reconstructed with image blending')

fprintf('SSIM blending: %1.4f\n', SSIM_reconstruction_2);

%% Leaf reconstruction evaluation
% Leaf reconstruction using image inpainting
healthy_leaf_to_model = map_healthy_leaf_to_model(leaf_seg, filter_size, leaves_back, id_damaged_leaf);
reconstructed_leaf_3  = leaf_inpaint(leaf_model, leaf_damaged_to_model);
[resultQuality_3, resultDistances_3] = leaf_evaluation_quality(healthy_leaf_to_model, reconstructed_leaf_3);
SSIM_reconstruction_3 = resultQuality_3(1);

figure; imshowpair(uint8(healthy_leaf_to_model), uint8(reconstructed_leaf_3), 'montage')
title('Health leaf and reconstructed with inpaint')
fprintf('SSIM inpaint: %1.4f\n', SSIM_reconstruction_3);



%%
leaf_back = map_ref_to_original(reconstructed_leaf_3, leaves_back(id_damaged_leaf,:));
figure; imshowpair(uint8(img_out), uint8(leaf_back(:,:,2) > 0))
figure; imshowpair(uint8(img_out), uint8(leaf_back), 'montage')

%% bite segments
original_bite_sign_to_model = map_bite_sign_to_model(defoliated_leaf_testData, bite_signature_testData, leaves_back, id_damaged_leaf, model_crop_size, model_crop_pad);
figure; imshowpair(uint8(original_bite_sign_to_model), uint8(bite_sign))
figure; imshowpair(uint8(original_bite_sign_to_model), uint8(bite_sign), 'montage')


