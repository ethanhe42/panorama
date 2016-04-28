%% merge images with no blending
%  input:   imgs - source images
%           mask - image mask
%           transforms - transformation matrices to transform each images
%                        into the new coordinate system
%           newHeight, newWidth - size of the new coordinate system
%  output:  newImg - merged image
function [ newImg ] = mergeNoBlend( imgs, mask, transforms, newHeight, newWidth )
% image information
height = size(imgs, 1);
width = size(imgs, 2);
nChannels = size(imgs, 3);
nImgs = size(imgs, 4);

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
        for k = 1 : nImgs
            p2 = backTransforms(:, :, k) * p1;
            p2 = p2 ./ p2(3);
            if p2(1) >= 1 && p2(1) < height && p2(2) >= 1 && p2(2) < width
                i = floor(p2(2));
                a = p2(2) - i;
                j = floor(p2(1));
                b = p2(1) - j;
                alpha = (1 - a) * (1 - b) * double(mask(j, i))...
                    + a * (1 - b) * double(mask(j, i + 1))...
                    + a * b * double(mask(j + 1, i + 1))...
                    + (1 - a) * b * double(mask(j + 1, i));
                if alpha > 0.9
                    newImg(y, x, :) = (1 - a) * (1 - b) * imgs(j, i, :, k)...
                        + a * (1 - b) * imgs(j, i + 1, :, k)...
                        + a * b * imgs(j + 1, i + 1, :, k)...
                        + (1 - a) * b * imgs(j + 1, i, :, k);
                    break;
                end
            end
        end
    end
end
end