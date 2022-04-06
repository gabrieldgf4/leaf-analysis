

function R2 = R_Squared(origImg, distImg)

origImg = double(origImg);
distImg = double(distImg);

[M, N] = size(origImg);

origMedia = (sum(sum(origImg))) ./ (M*N);

num = sum(sum((origImg - distImg).^2));
den = sum(sum((origImg - origMedia).^2));

R2 = 1 - (num/den);

end
