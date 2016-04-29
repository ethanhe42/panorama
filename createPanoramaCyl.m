function [ newImg ] = createPanoramaCyl( imgs, f, k1, k2, loop, matchExp, blend )
if loop
    imgs(:, :, :, end + 1) = imgs(:, :, :, 1);
end
nImgs = size(imgs, 4);
cylImgs = zeros(size(imgs), 'like', imgs);

t=cputime;
for i = 1 : nImgs
    cylImgs(:, :, :, i) = warp(imgs(:, :, :, i), f);
end
disp(['warping:',int2str(cputime-t),' sec']);
t=cputime;

translations = estimateTranslations(cylImgs);

disp(['SIFT & RANSAC: ',int2str(cputime-t),' sec']);
t=cputime;

if matchExp
     cylImgs = matchExposures(cylImgs, translations, loop);
end

accTranslations = zeros(size(translations));
accTranslations(:, :, 1) = translations(:, :, 1);
for i = 2 : nImgs
    accTranslations(:, :, i) = accTranslations(:, :, i - 1) * translations(:, :, i);
end

% end to end adjustment
width = size(cylImgs, 2);
height = size(cylImgs, 1);
newWidth = abs(round(accTranslations(2, 3, end))) + width;
if loop
    % \delta x / \delta y
    driftSlope = accTranslations(1, 3, end) / accTranslations(2, 3, end);
    
    newHeight = height;
    % y shift is negative
    if accTranslations(2, 3, end) < 0
        accTranslations(2, 3, :) = accTranslations(2, 3, :) - accTranslations(2, 3, end);
        accTranslations(1, 3, :) = accTranslations(1, 3, :) - accTranslations(1, 3, end);
    end
    driftMatrix = [1 -driftSlope driftSlope; 0 1 0; 0 0 1];
    for i = 1 : nImgs
        accTranslations(:, :, i) = driftMatrix * accTranslations(:, :, i);
    end
else
    maxY = height;
    minY = 1;
    minX = 1;
    for i = 2 : nImgs 
        maxY = max(maxY, accTranslations(1,3,i)+height);
        minY = min(minY, accTranslations(1,3,i));
        minX=min(minX,accTranslations(2,3,i));
    end
    newHeight = ceil(maxY) - floor(minY) + 1;
    accTranslations(2, 3, :) = accTranslations(2, 3, :) - floor(minX);
    accTranslations(1, 3, :) = accTranslations(1, 3, :) - floor(minY);
end

disp(['end2end alignment:',int2str(cputime-t),' sec']);
t=cputime;

% image mask - 1 for image & 0 for border
mask = ones(height, width);
mask = logical(warp(mask, f));

newImg = mergeAlpha(cylImgs, mask, accTranslations, newHeight, newWidth);

disp(['alpha merging:',int2str(cputime-t),' sec']);
t=cputime;

end

