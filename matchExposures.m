%% match exposures across images
%  input:   imgs - source images
%           transforms - pairwise transformation matrices
%           loop - is is a full panorama?
%  output:  newImgs - exposure matched images
function [ newImgs ] = matchExposures( imgs, transforms, loop )
% image information
nImgs = size(imgs, 4);

% pairwise matching
gammas = ones(nImgs, 1);
for i = 2 : nImgs
    gammas(i) = matchPair(imgs(:, :, :, i - 1), imgs(:, :, :, i), transforms(:, :, i));
end

% accumulating gammas
if loop
    % global optimization
    logGammas = log(gammas);
    logGammas(1) = [];
    A = eye(nImgs - 2);
    A = [A; -ones(1, nImgs - 2)];
    newLogGammas = A \ logGammas;
    newLogGammas = [0; newLogGammas];
    newGammas = exp(newLogGammas);
    
    accGammas = ones(nImgs, 1);
    for i = 2 : nImgs - 1
        accGammas(i) = accGammas(i - 1) * newGammas(i);
    end
else
    accGammas = ones(nImgs, 1);
    for i = 2 : nImgs
        accGammas(i) = accGammas(i - 1) * gammas(i);
    end
end

% gamma correction
newImgs = zeros(size(imgs), 'uint8');
for i = 1 : nImgs
    newImgs(:, :, :, i) = correctGamma(imgs(:, :, :, i), accGammas(i));
end
end

%% match a pair of images
%  input:   img1 - reference image
%           img2 - source image
%           transform - matrix to transform img2 to img1
%  output:  gamma - gamma value to match exposures
function [ gamma ] = matchPair(img1, img2, transform)
% parameters
sampleRatio = 0.01;
outlierThreshold = 1.0;
nIters = 1000;
alpha = 1; % learning rate

% image information
width = size(img1, 2);
height = size(img1, 1);

% coverting to La*b*
labImg1 = rgb2lab(img1);
labImg2 = rgb2lab(img2);

% sampling correspondences
nPxs = numel(img1);
nSmps = round(nPxs * sampleRatio);
smps = zeros(nSmps, 2);
k = 1;
while true
    p2 = [randi([1 height]); randi([1 width]); 1];
    p1 = transform * p2;
    p1 = p1 ./ p1(3);
    if p1(1) >= 1 && p1(1) < height && p1(2) >= 1 && p1(2) < width
        i = floor(p1(2));
        a = p1(2) - i;
        j = floor(p1(1));
        b = p1(1) - j;
        smp1 = (1 - a) * (1 - b) * labImg1(j, i, 1)...
            + a * (1 - b) * labImg1(j, i + 1, 1)...
            + a * b * labImg1(j + 1, i + 1, 1)...
            + (1 - a) * b * labImg1(j + 1, i, 1);
        smp2 = labImg2(p2(1), p2(2), 1);
        if smp1 > outlierThreshold && smp2 > outlierThreshold
            smps(k, 1) = smp1 / 100;
            smps(k, 2) = smp2 / 100;
            k = k + 1;
            if k > nSmps
                break;
            end
        end
    end
end

% fitting correction curve
gamma = 1;
for i = 1 : nIters
    gamma = gamma - alpha * sum((smps(:, 2) .^ gamma - smps(:, 1)) .*...
        log(smps(:, 2)) .* (smps(:, 2) .^ gamma)) / nSmps;
end

% visualizing results
% figure;
% scatter(smps(:, 2), smps(:, 1));
% hold on;
% xplot = 0:0.01:1;
% yplot = xplot .^ gamma;
% plot(xplot, yplot);
end

%% apply gamma correction
%  input:   img - source image
%           gamma - gamma value to match exposures
%  output:  newImg - gamma corrected image
function [ newImg ] = correctGamma(img, gamma)
labImg = rgb2lab(img);
labImg(:, :, 1) = (labImg(:, :, 1) / 100) .^ gamma * 100;
newImg = lab2rgb(labImg, 'OutputType', 'uint8');
end
