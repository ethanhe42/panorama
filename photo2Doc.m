%% align an image as a document (use homography to transform it into a rectangle)
%  input:   img - source image to align
%  output:  newImg - the image aligned as a document
function [ newImg ] = photo2Doc( img )
% image information
width = size(img, 2);
height = size(img, 1);
channel = size(img, 3);
dimension = length(img);

% thresholding
imgDist = uint8(sqrt((sum(double(255 - img) .^ 2, 3))));
windowSize = round(dimension * 0.5);
imgMean = imfilter(imgDist, fspecial('average', windowSize), 'replicate');
imgDiff = single(imgDist) - single(imgMean);
thresh = graythresh(imgDiff); 
imgBW = imcomplement(im2bw(imgDiff, thresh));
imgBWFilled = imfill(imgBW, 8, 'holes');
structureSize = round(dimension * 0.001);
se = strel('disk', structureSize);
erodeTimes = 0;
imgBWRect = imgBWFilled;
CC = bwconncomp(imgBWRect);
while CC.NumObjects > 1
    imgBWRect = imerode(imgBWRect, se);
    erodeTimes = erodeTimes + 1;
    CC = bwconncomp(imgBWRect);
end
se = strel('square', erodeTimes * structureSize);
for i = 1 : erodeTimes
    imgBWRect = imdilate(imgBWRect, se);
end

% corner detection
cornerFilterRadius = round(dimension / 100) * 2 + 1;
cornerFilter = fspecial('gaussian', [cornerFilterRadius 1], cornerFilterRadius / 3);
corners = corner(imgBWRect, 4, 'FilterCoefficients', cornerFilter);
corners(:, [1, 2]) = corners(:, [2, 1]);

dists = corners(:, 1) .^ 2 + corners(:, 2) .^ 2;
[~, minIdx] = min(dists);
upperLeft = corners(minIdx, :);
corners(minIdx, :) = [];
dists = (corners(:, 1) - upperLeft(1)) .^ 2 + (corners(:, 2) - upperLeft(2)) .^ 2;
[~, maxIdx] = max(dists);
lowerRight = corners(maxIdx, :);
corners(maxIdx, :) = [];
if dot(corners(1, :) - upperLeft, lowerRight - upperLeft) > 0
    upperRight = corners(1, :);
    lowerLeft = corners(2, :);
else
    upperRight = corners(2, :);
    lowerLeft = corners(1, :);
end

% homography transformation
newWidth = round((pdist2(upperLeft, upperRight) + pdist2(lowerLeft, lowerRight)) / 2);
newHeight = round((pdist2(upperLeft, lowerLeft) + pdist2(upperRight, lowerRight)) / 2);
newDimension = max([newWidth newHeight]);
cp1 = [upperLeft; upperRight; lowerRight; lowerLeft];
cp2 = [1, 1; 1, newWidth; newHeight, newWidth; newHeight, 1];

H = solveHomography(cp1, cp2);

newImgRaw = zeros([newHeight newWidth channel], 'uint8');
for y = 1 : newHeight
    for x = 1 : newWidth
        p1 = [y; x; 1];
        p2 = H * p1;
        p2 = p2 ./ p2(3);
        if p2(1) >= 1 && p2(1) < height && p2(2) >= 1 && p2(2) < width
            i = floor(p2(2));
            a = p2(2) - i;
            j = floor(p2(1));
            b = p2(1) - j;
            newImgRaw(y, x, :) = (1 - a) * (1 - b) * img(j, i, :)...
                + a * (1 - b) * img(j, i + 1, :)...
                + a * b * img(j + 1, i + 1, :)...
                + (1 - a) * b * img(j + 1, i, :);
        end
    end
end

% image enhancement
filterRadius = round(newDimension / 20) * 2 + 1;
filter = fspecial('gaussian', [filterRadius filterRadius], filterRadius / 3);
newImgLFiltered = imfilter(newImgRaw, filter, 'replicate');
newImg = uint8(double(newImgRaw) ./ double(newImgLFiltered) * 255);

end

