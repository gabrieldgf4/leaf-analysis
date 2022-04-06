function experiment(file,param,GTfield)

if ~exist('inpaintBCT')
    fid = fopen('Readme.txt');
    str = textscan(fid, '%s', 'Delimiter','\n'); str = str{1};
    fclose(fid);
    S=sprintf('%s\n',str{1:end-1});
    S=sprintf('%s%s <a href="matlab:getCode">download v1.0</a> from github! \n',S,str{end});
    disp(S)
    return;   
end

screensize=get(0,'ScreenSize');
fig=figure('Outerposition',screensize,'Units',get(0,'Units'));
set(fig,'DoubleBuffer','on');
color = 204;    % Matlab's gray

if isempty(param), param = [5 25 1.4 4]; end

damaged = 'data/';
reconstructed = 'results/';
[succ,message] = mkdir(reconstructed);

in    = imread([damaged file '.png']); 
mask  = imread([damaged file '_mask.png']);
[m,n,k] = size(in);
if k == 3
    luminance = [0.299 0.587 0.114]; % luminance of RGB color images
else
    luminance = [];                  % use arithmetic mean otherwise   
end

% prepare
bw_mask = getMask(double(in),double(mask));
combparam  = [param 0 255 luminance];

if nargin < 3
    tic;
    out = inpaintBCT(double(mask),'orderD',bw_mask,'guidanceC',combparam);
    t=toc;
else
    tic;
    out = inpaintBCT(double(mask),'orderD',bw_mask,'guidanceC',combparam,'guidanceD',GTfield);
    t=toc;
end

ind = find(bw_mask);
mask = color*(1-bw_mask);
fill = out;
for i=1:k
    fill(:,:,i) = bw_mask .* fill(:,:,i) + mask;
end
out = uint8(out); 
fill = uint8(fill);
mask = uint8(mask);

subplot(2,2,1); imshow(in);   title(file); 
subplot(2,2,2); imshow(mask); title([file ' mask']);
subplot(2,2,4); imshow(fill); title('fill-in (fast inpainting)');       
subplot(2,2,3); imshow(out);  title(['fast inpainting' ...
    sprintf(' (%2.2g sec)',t)]); 

fileout = [reconstructed file sprintf('_%0.3g_%0.3g_%0.3g_%0.3g',param)];
fileout = strrep(fileout,'.','p');

imwrite(out,[fileout '.png']);