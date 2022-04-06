% Apresentado na Disciplina Metodos Empiricos

function RMSE = RootMeanSquareError(origImg, distImg)

origImg = double(origImg)+1;
distImg = double(distImg)+1;

[M, N] = size(origImg);
%RMSE = sqrt(nansum(nansum(((distImg - origImg) ./ origImg).^2)) / (M*N));

RMSE = sqrt(nansum(nansum((distImg - origImg).^2)) / (M*N));


end
