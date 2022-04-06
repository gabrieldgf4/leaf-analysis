%Program for Normalized Cross Correlation Calculation

%Author : Athi Narayanan S
%M.E, Embedded Systems,
%K.S.R College of Engineering
%Erode, Tamil Nadu, India.
%http://sites.google.com/site/athisnarayanan/
%s_athi1983@yahoo.co.in

function NK = NormalizedCrossCorrelation(origImg, distImg)

origImg = double(origImg);
distImg = double(distImg);

NK = nansum(nansum(origImg .* distImg)) ./ nansum(sum(origImg .* origImg));