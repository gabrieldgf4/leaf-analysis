% prepare_data selects the images to be used in the template leaf
% construction and to be used in the validation of the template
%
%   'images' images in a cell structure
%
%    qtty_leaf_models - quantity of leaves to construct the leaf models
%     
%    qtty_leaf_test - quantity of leaves to be tested
%
%   'mix' if mix equal to 1, then the images are mixed before the
%           separation in train and test
%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)

% [healthy_leaf_modelData, healthy_leaf_testData] = prepare_data_v2(images, 100, 100, 1);

function [healthy_leaf_modelData, healthy_leaf_testData] = prepare_data(images, qtty_leaf_models, qtty_leaf_test, mix)

rng shuffle; % creates a different seed each time

qtty_images = length(images);

if (qtty_leaf_models + qtty_leaf_test) > qtty_images
    error('number of samples is higher than the dataset');
end


if mix==1
    ny = qtty_images;
    shuffle = randsample(1:ny,ny);
    images = images(shuffle);
end

% Part 1
first_image = randi([1, qtty_images]);
last_image = first_image + qtty_leaf_models -1;
if last_image > qtty_images
    first_image = qtty_images - qtty_leaf_models + 1;
    last_image = qtty_images;
end

healthy_leaf_modelData = images(first_image:last_image);

% Part 2
% remove the previous selected images from the dataset
idx = true(1,qtty_images);
idx(1,first_image:last_image) = 0;
images = images(idx);

qtty_images = length(images);

first_image = randi([1, qtty_images]);
last_image = first_image + qtty_leaf_test -1;
if last_image > qtty_images
    first_image = qtty_images - qtty_leaf_test + 1;
    last_image = qtty_images;
end

healthy_leaf_testData = images(first_image:last_image);

end

