URL='https://github.com/maerztom/inpaintBCT/archive/v1.0.zip';
file = 'inpaintBCT_v1_0.zip';
[file,path] = uiputfile(file,'Save file as');
urlwrite(URL,[path file]);