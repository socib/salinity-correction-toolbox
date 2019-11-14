function save_figure( fnameOut, imageDir, figObject )
%Saves figues as fig and png


imageOutPath = strcat(imageDir,fnameOut);

saveFigure(figObject, imageOutPath);
img = getframe(figObject);
imwrite(img.cdata, [imageOutPath, '.png']);


end

