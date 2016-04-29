function [ newImg ] = mergeAlpha( imgs, mask, transforms, newHeight, newWidth )
% image information
height = size(imgs, 1);
width = size(imgs, 2);
nChannels = size(imgs, 3);
nImgs = size(imgs, 4);

% alpha mask
mask = imcomplement(mask);

mask = bwdist(mask, 'euclidean');
mask = mask ./ max(max(mask));

% backward transformation
backTransforms = zeros(size(transforms));
for i = 1 : nImgs
    backTransforms(:, :, i) = inv(transforms(:, :, i));
end

% image merging
newImg = zeros([newHeight newWidth nChannels], 'uint8');
for y = 1 : newHeight
    for x = 1 : newWidth
        p1 = [y; x; 1];
        pixelSum = zeros(nChannels, 1);
        alphaSum = 0;
        for k = 1 : nImgs
            p2 = backTransforms(:, :, k) * p1;
            p2 = p2 ./ p2(3);
            if p2(1) >= 1 && p2(1) < height && p2(2) >= 1 && p2(2) < width
                i = floor(p2(2));
                j = floor(p2(1));
                pixel =imgs(j, i, :, k);
                alpha =mask(j, i);
                pixelSum = pixelSum + double(squeeze(pixel)) * double(alpha);
                alphaSum = alphaSum + double(alpha);
            end
        end
        newImg(y, x, :) = pixelSum / alphaSum;
    end
end
end
