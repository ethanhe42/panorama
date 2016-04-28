%% estimate pairwise homographies
%  input:   imgs - source images
%  output:  homographies - homographies matrices to align each pair of images
function [ homographies ] = estimateHomographies( imgs )
% parameters
edgeThresh = 10;
successProb = 0.99;
inlierRatio = 0.3;
epsilon = 1.5;

% image information
nImgs = size(imgs, 4);

% pairwise homography estimation
homographies = zeros(3, 3, nImgs);
homographies(:, :, 1) = eye(3);
[f2, d2] = getSIFTFeatures(imgs(:, :, :, 1), edgeThresh);
for i = 2 : nImgs
    f1 = f2;
    d1 = d2;
    [f2, d2] = getSIFTFeatures(imgs(:, :, :, i), edgeThresh);
    [matches, ~] = getPotentialMatches(f1, d1, f2, d2);
    homographies(:, :, i) = RANSAC(successProb, inlierRatio, 4, matches, epsilon, @solveHomography, @compError);
end
end

