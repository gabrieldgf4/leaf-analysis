%
% Gabriel da Silva Vieira (INF/UFG, IFGoiano - 2020)
%

function [resultQuality, resultDistances] = leaf_evaluation_quality(healthy_leaf_to_model, reconstructed_leaf)

%-------
% Quality evaluation
% Structural Similarity Index (SSIM) [0..1]
SSIM = ssim(reconstructed_leaf, healthy_leaf_to_model); 

% Complex-Wavelet Structural SIMilarity (CW-SSIM) [0..1]
%CWSSIM = cwssim_index(healthy_leaf_to_model, reconstructed_leaf,2,16,0,0); 

%Normalized Cross-Correlation [0..1]
%NCC = normxcorr2(reconstructed_leaf, healthy_leaf_to_model);
NCC = NormalizedCrossCorrelation(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));

%Normalized Absolute Error [0 is better]
NAE = NormalizedAbsoluteError(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));

% Mean Bias Error [0..1]
MBE = MeanBiasError(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));

% Mean Mean Error [0..1] 
MSE = immse(reconstructed_leaf, healthy_leaf_to_model);
%MSE = MeanSquareError2(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));

%Root Mean Square Error [0..1]
RMSE = sqrt(MSE);
%RMSE = RootMeanSquareError(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));

%Peak Signal to Noise Ratio, [0..48.13 db]
PSNR = psnr(reconstructed_leaf, healthy_leaf_to_model);
%PSNR = PeakSignaltoNoiseRatio(healthy_leaf_to_model(:,:,2), reconstructed_leaf(:,:,2));    

resultQuality = [ SSIM, NCC, NAE, MBE, MSE, RMSE, PSNR ];


%--------
% Distances
% Reconstructed Leaf
r1 = reconstructed_leaf(:,:,1); 
g1 = reconstructed_leaf(:,:,2); 
b1 = reconstructed_leaf(:,:,3);

% Ground Truth
r2 = healthy_leaf_to_model(:,:,1); 
g2 = healthy_leaf_to_model(:,:,2); 
b2 = healthy_leaf_to_model(:,:,3);

a = [r1(:)', g1(:)', b1(:)'];
b = [r2(:)', g2(:)', b2(:)'];

d1 = pdist2(a, b, 'euclidean');
d2 = pdist2(a, b, 'cityblock');
d3 = pdist2(a, b, 'chebychev');
d4 = pdist2(a, b, 'cosine');
d5 = pdist2(a, b, 'correlation');
d6 = pdist2(a, b, 'hamming');
d7 = pdist2(a, b, 'jaccard');
d8 = pdist2(a, b, 'spearman');

resultDistances = [ d1, d2, d3, d4, d5, d6, d7, d8 ];
   

end