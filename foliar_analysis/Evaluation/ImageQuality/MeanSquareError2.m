% Apresentado na Disciplina Metodos Empiricos

function MSE = MeanSquareError2(origImg, distImg)

origImg = double(origImg)+1;
distImg = double(distImg)+1;

[M, N] = size(origImg);
MSE = nansum(nansum(((distImg - origImg) ./ origImg).^2)) / (M*N);

end