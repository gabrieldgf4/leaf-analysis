function denoising(file,param,th)

damaged = 'data/';

in = imread([damaged file '.png']);
mask = (in<th) | (in>255-th); 
out = in; out(mask) = 128; 
imwrite(out,[damaged file '_mask.png']);
experiment(file,param);
delete([damaged file '_mask.png']);