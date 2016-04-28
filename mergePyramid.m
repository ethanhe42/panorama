%% merge images using Pyramid blending
%  input:   imgs - source images
%           transforms - transformation matrices to transform each images
%                        into the new coordinate system
%           newHeight - height of the new coordinate system
%  output:  finalImg - merged image
function [ finalImg ] = mergePyramid( imgs, transforms, newHeight )

nImgs = size(imgs, 4);

% blend and build new image iteratively
[newImg, extent1] = transformImage(imgs(:,:,:,1), transforms(:,:,1), newHeight);
for i = 2:nImgs
    [img2, extent2] = transformImage(imgs(:,:,:,i), transforms(:,:,i), newHeight);
    
    % compute image overlap
    if (extent1.midXR > extent2.midXL) && (extent1.midXR < extent2.midXR) % left is img 1
        left = newImg;
        right = img2;
        overlap = extent1.maxX - extent2.minX;
    elseif (extent1.midXL > extent2.midXL) && (extent1.midXL < extent2.midXR) % left is img 2
        left = img2;
        right = newImg;
        overlap = extent2.maxX - extent1.minX;
    else
        disp('Error! Consecutive images do not overlap')
        exit(1)
    end

    % build left & right, non-overlapping and overlapping regions
    wL = size(left, 2);
    wR = size(right, 2);
    rightNonOverlap = right(: , (overlap+1):wR, :);
    leftNonOverlap = left(: , 1:(wL-overlap), :);
    rightOverlap = right(: , 1:overlap, :);
    leftOverlap = left(: , (wL-overlap+1):wL, :);

    % new image with pyramid blending
    blendedOverlap = pyramidBlending(overlap, leftOverlap, rightOverlap);
    newImg = [leftNonOverlap blendedOverlap rightNonOverlap];
    extent1 = extent2;
end

% convert final image to uint8
finalImg = uint8(newImg);
end

%% Pyramid blending technique
% Reference: http://persci.mit.edu/pub_pdfs/spline83.pdf
%  input:   overlapPixels - the width of the overlap region
%           left - overlap region taken from the left image
%           right - overlap region taken from the right image
%  output:  newOverlap - the blended overlap region
function [newOverlap] = pyramidBlending(overlapPixels, left, right)
levelFactor = 0.8;
N = floor(log2(overlapPixels) * levelFactor);
width = size(left, 2);
height = size(left, 1);

% initialize matrices for gaussian pyramid
% GA = zeros([size(left) N+1]);
% GB = zeros([size(right) N+1]);
% GA(:,:,:,1) = left(:,:,:);
% GB(:,:,:,1) = right(:,:,:);
GA = cell(1, N+1);
GB = cell(1, N+1);
GA{1} = im2double(left);
GB{1} = im2double(right);

% build gaussian pyramid
% gKernel = fspecial('gaussian',5);
% for i = 2:N+1
%     GA(:,:,:,i) = imfilter(GA(:,:,:,i-1),gKernel,'conv');
%     GB(:,:,:,i) = imfilter(GB(:,:,:,i-1),gKernel,'conv');
% end
for i = 2:N+1
    GA{i} = impyramid(GA{i-1}, 'reduce');
    GB{i} = impyramid(GB{i-1}, 'reduce');
end
for i = N:-1:1
    osz = size(GA{i+1}) * 2 - 1;
    % GA{i} = GA{i}(1:osz(1),1:osz(2),:);
    GA{i} = imresize(GA{i}, [osz(1) osz(2)]);
    % GB{i} = GB{i}(1:osz(1),1:osz(2),:);
    GB{i} = imresize(GB{i}, [osz(1) osz(2)]);
end

% build laplacian pyramid from difference of gaussians
% LA = zeros([size(left) N+1]);
% LB = zeros([size(right) N+1]);
% for i = 1:N
%     LA(:,:,:,i) = GA(:,:,:,i) - GA(:,:,:,i+1);
%     LB(:,:,:,i) = GB(:,:,:,i) - GB(:,:,:,i+1);
% end
% LA(:,:,:,N+1) = GA(:,:,:,N+1);
% LB(:,:,:,N+1) = GB(:,:,:,N+1);
LA = cell(1, N+1);
LB = cell(1, N+1);
for i = 1:N
	LA{i} = GA{i} - impyramid(GA{i+1}, 'expand');
    LB{i} = GB{i} - impyramid(GB{i+1}, 'expand');
end
LA{N+1} = GA{N+1};
LB{N+1} = GB{N+1};

% build each side of the overlap region by summing the laplacians
% LS = zeros(size(LA));
% for l = 1:N+1
%     for i = 1:size(LA,1)
%         for j = 1:size(LA,2)
%             if j < (2^N)
%                 LS(i,j,:,l) = LA(i,j,:,l);
%             elseif j == (2^N)
%                 LS(i,j,:,l) = (LA(i,j,:,l) + LB(i,j,:,l)) ./ 2;
%             else
%                 LS(i,j,:,l) = LB(i,j,:,l);
%             end
%         end
%     end
% end
LS = cell(1, N+1);
for l = 1:N+1
    centerLine = (size(LA{l}, 2) + 1) / 2;
    for i = 1:size(LA{l}, 1)
        for j = 1:size(LA{l}, 2)
            if j < centerLine
                LS{l}(i,j,:) = LA{l}(i,j,:);
            elseif j == centerLine
                LS{l}(i,j,:) = (LA{l}(i,j,:) + LB{l}(i,j,:)) ./ 2;
            else
                LS{l}(i,j,:) = LB{l}(i,j,:);
            end
        end
    end
end

% newOverlap = zeros(size(left));
% for i = 1: N+1
%     newOverlap(:,:,:) = newOverlap(:,:,:) + LS(:,:,:,i);
% end
newOverlap = LS{N+1};
for i = N:-1:1
    newOverlap = LS{i} + impyramid(newOverlap, 'expand');
end
newOverlap = imresize(newOverlap, [height width]);
newOverlap = im2uint8(newOverlap);
end

%% Applies a transform to build a section of the final image
%  input:   img - the img to transform
%           transform - the 3x3 transform matrix to apply to the image
%           fullImageHeight - the height (in pixels) of the final image
%  output:  transImg - the image after applying the transform
%           extent - a structure that contains critical coordinate
%           information of this image in the final image reference frame
function [transImg, extent] = transformImage(img, transform, fullImageHeight)
    w = size(img,2);
    h = size(img,1);
    
    % compute critical points (corners) after tranform
    topRight = transform * [1 ; w ; 1];
    topRight = floor(topRight ./ topRight(3));
    
    topLeft = transform * [1 ; 1 ; 1];
    topLeft = floor(topLeft ./ topLeft(3));
    
    bottomRight = transform * [h ; w ; 1];
    bottomRight = floor(bottomRight ./ bottomRight(3));
    
    bottomLeft = transform * [h ; 1 ; 1];
    bottomLeft = floor(bottomLeft ./ bottomLeft(3));
    
    mat = [ topRight, topLeft, bottomRight, bottomLeft ];
    
    % build image extent
    [matMax, indMax] = max(mat,[],2);
    [matMin, indMin] = min(mat,[],2);
    maxY = matMax(1);
    minY = matMin(1);
    maxX = matMax(2);
    minX = matMin(2);
    
    midX = mat(2 , :);
    midX([indMax(2), indMin(2)]) = [];
    midX = sort(midX);

    extent.midXL = midX(1);
    extent.midXR = midX(2);
    extent.maxX = maxX;
    extent.maxY = maxY;
    extent.minY = minY;
    extent.minX = minX;
    extent.topR = mat(1);
    extent.topL = mat(2);
    extent.bottomR = mat(3);
    extent.bottomL = mat(4);
    
    deltaY = maxY - minY;
    deltaX = maxX - minX;
    
    % produce full warped image
    transImg = zeros(fullImageHeight, deltaX, 3, 'uint8');
    for y = 1:fullImageHeight
        for x = minX:maxX
            p1 = [y; x; 1];
            p2 = transform \ p1;
            p2 = p2 ./ p2(3);
            if p2(1) >= 1 && p2(1) < size(img,1) && p2(2) >= 1 && p2(2) < size(img,2)
                i = floor(p2(2));
                a = p2(2) - i;
                j = floor(p2(1));
                b = p2(1) - j;
                transImg(y, x - minX + 1, :) = (1 - a) * (1 - b) * img(j, i, :)...
                    + a * (1 - b) * img(j, i + 1, :)...
                    + a * b * img(j + 1, i + 1, :)...
                    + (1 - a) * b * img(j + 1, i, :);
            end
        end
    end
end