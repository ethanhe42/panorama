%% create panorama image using homography
%  input:   imgs - source images
%           matchExp - match exposures across images?
%           blend - use which blending technique? 'Alpha' or 'Pyramid'
%  output:  newImg - panorama image
function [ newImg ] = createPanoramaPla( imgs, matchExp, blend )
% pairwise transformation estimation
homographies = estimateHomographies(imgs);

% exposure matching
if matchExp
    imgs = matchExposures(imgs, homographies, false);
end

% transformation accumulation
nImgs = size(imgs, 4);
centerIdx = floor((nImgs + 1) / 2);
accHomographies = zeros(size(homographies));
accHomographies(:, :, centerIdx) = eye(3);
for i = centerIdx - 1 : -1 : 1
    accHomographies(:, :, i) = accHomographies(:, :, i + 1) / homographies(:, :, i + 1);
end
for i = centerIdx + 1 : nImgs
    accHomographies(:, :, i) = accHomographies(:, :, i - 1) * homographies(:, :, i);
end

% new size computation & transformation refinement
width = size(imgs, 2);
height = size(imgs, 1);
maxX = width;
minX = 1;
maxY = height;
minY = 1;
frame = [[1; 1; 1], [height; 1; 1], [1; width; 1], [height; width; 1]];
for i = 1 : nImgs 
    newFrame = accHomographies(:, :, i) * frame;
    newFrame(:, 1) = newFrame(:, 1) ./ newFrame(3, 1);
    newFrame(:, 2) = newFrame(:, 2) ./ newFrame(3, 2);
    newFrame(:, 3) = newFrame(:, 3) ./ newFrame(3, 3);
    newFrame(:, 4) = newFrame(:, 4) ./ newFrame(3, 4);
    maxX = max(maxX, max(newFrame(2, :)));
    minX = min(minX, min(newFrame(2, :)));
    maxY = max(maxY, max(newFrame(1, :)));
    minY = min(minY, min(newFrame(1, :)));
end
newWidth = ceil(maxX) - floor(minX) + 1;
newHeight = ceil(maxY) - floor(minY) + 1;
offsetX = 1 - floor(minX);
offsetY = 1 - floor(minY);
offsetMat = [1 0 offsetY; 0 1 offsetX; 0 0 1];
for i = 1 : nImgs
    accHomographies(:, :, i) = offsetMat * accHomographies(:, :, i);
end

% image mask - 1 for image & 0 for border
mask = logical(ones(height, width));

% merging images
if strcmp(blend, 'Alpha')
    newImg = mergeAlpha(imgs, mask, accHomographies, newHeight, newWidth);
elseif strcmp(blend, 'Pyramid')
	newImg = mergePyramid( imgs, accHomographies, newHeight );
else % if strcmp(blend, 'NoBlend')
    newImg = mergeNoBlend(imgs, mask, accHomographies, newHeight, newWidth);
end
end

