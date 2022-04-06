% apresentado na Disciplina Metodos Empiricos

function MBE = MeanBiasError(origImg, distImg)

origImg = double(origImg)+1;
distImg = double(distImg)+1;

[M, N] = size(origImg);

diff = (distImg - origImg);
%diff(diff==0) = 1;

MBE = nansum(nansum((diff ./ origImg))) / (M*N);

end

