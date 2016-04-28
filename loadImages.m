%% Simple function to load a list of images
%  input:   imgFiles - a cell array of strings, each string is a path to an
%  image to be loaded
%  output:  imgs - a 4-d matrix of the the loaded images
function imgs = loadImages(imgFiles)
imgNum = length(imgFiles);
imgInfo = imfinfo(char(imgFiles(1)));
height = imgInfo.Height;
width = imgInfo.Width;
imgs = zeros(height,width,3,imgNum,'uint8');
for i=1:imgNum
    imgs(:,:,:,i) = imread(char(imgFiles(i)));
end
end

