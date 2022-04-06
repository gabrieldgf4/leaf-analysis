%Program for Peak Signal to Noise Ratio Calculation

%Author : Athi Narayanan S
%M.E, Embedded Systems,
%K.S.R College of Engineering
%Erode, Tamil Nadu, India.
%http://sites.google.com/site/athisnarayanan/
%s_athi1983@yahoo.co.in

% Ver
% https://www.researchgate.net/post/What_are_the_max_and_min_values_of_SNR_PSNR_Can_be_the_values_greater_than_40dB5

function PSNR = PeakSignaltoNoiseRatio(origImg, distImg)

origImg = double(origImg);
distImg = double(distImg);

[M N] = size(origImg);
error = origImg - distImg;
MSE = nansum(nansum(error .* error)) / (M * N);

if isinf(log10(MSE)) %(MSE > 0)
    %PSNR = 10*log(255*255/MSE) / log(10);
    PSNR = 20*log10(255);
 else
     PSNR = 20*log10(255) - 10*log10(MSE); %PSNR = 99;
end