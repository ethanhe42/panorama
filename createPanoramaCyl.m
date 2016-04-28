%% create panorama image using cylindrical projection
%  input:   imgs - source images
%           f - local length
%           k1, k2 - radial distortion parameters
%           loop - is is a full panorama?
%           matchExp - match exposures across images?
%           blend - use which blending technique? 'Alpha' or 'Pyramid'
%  output:  newImg - panorama image
function [ newImg ] = createPanoramaCyl( imgs, f, k1, k2, loop, matchExp, blend )
% putting a copy of the first image to the end
if loop
    imgs(:, :, :, end + 1) = imgs(:, :, :, 1);
end

% cylindrical warping
nImgs = size(imgs, 4);
cylImgs = zeros(size(imgs), 'like', imgs);
for i = 1 : nImgs
    cylImgs(:, :, :, i) = cylProj(imgs(:, :, :, i), f, k1, k2);
end

% pairwise transformation estimation
translations = estimateTranslations(cylImgs);

% exposure matching
if matchExp
    cylImgs = matchExposures(cylImgs, translations, loop);
end

% transformation accumulation
accTranslations = zeros(size(translations));
accTranslations(:, :, 1) = translations(:, :, 1);
for i = 2 : nImgs
    accTranslations(:, :, i) = accTranslations(:, :, i - 1) * translations(:, :, i);
end

% new size computation & transformation refinement
width = size(cylImgs, 2);
height = size(cylImgs, 1);
if loop
    driftSlope = accTranslations(1, 3, end) / accTranslations(2, 3, end);
    newWidth = abs(round(accTranslations(2, 3, end))) + width;
    newHeight = height;
    if accTranslations(2, 3, end) < 0
        accTranslations(2, 3, :) = accTranslations(2, 3, :) - accTranslations(2, 3, end);
        accTranslations(1, 3, :) = accTranslations(1, 3, :) - accTranslations(1, 3, end);
    end
    driftMatrix = [1 -driftSlope driftSlope; 0 1 0; 0 0 1];
    for i = 1 : nImgs
     %   accTranslations(:, :, i) = driftMatrix * accTranslations(:, :, i);
    end
else
    maxX = width;
    minX = 1;
    maxY = height;
    minY = 1;
    frame = [[1; 1; 1], [height; 1; 1], [1; width; 1], [height; width; 1]];
    for i = 2 : nImgs 
        newFrame = accTranslations(:, :, i) * frame;
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
    accTranslations(2, 3, :) = accTranslations(2, 3, :) + offsetX;
    accTranslations(1, 3, :) = accTranslations(1, 3, :) + offsetY;
end

% image mask - 1 for image & 0 for border
mask = ones(height, width);
mask = logical(cylProj(mask, f, k1, k2));

% merging images
if strcmp(blend, 'Alpha')
    newImg = mergeAlpha(cylImgs, mask, accTranslations, newHeight, newWidth);
elseif strcmp(blend, 'Pyramid')
    newImg = mergePyramid( cylImgs, accTranslations, newHeight );
else % if strcmp(blend, 'NoBlend')
    newImg = mergeNoBlend(cylImgs, mask, accTranslations, newHeight, newWidth);
end

% cropping image
if loop
    newImg = newImg(:, width / 2 : newWidth - width / 2, :);
end
end

