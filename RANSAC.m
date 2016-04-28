%% RANSAC function for feature matching. Computes the best setting of parameters.
%  input:   P - probability of having at least 1 success (0.99 is a good setting)
%           p - probability of a real inlier (can be pesimistic, try 0.5)
%           n - number of samples each run
%           data - the data points of interest
%           epsilon - threshold for inlier
%           settingFunctionHandle - handle to function to compute parameter values (homography, translation, etc.)
%           SSDFunctionHanle - handle to function to compute the error measure
%  output:  H - homography matrix that transforms points in image2
%               to points in image1, 3 x 3 matrix
function [bestSetting] = RANSAC(P, p, n, data, epsilon, settingFunctionHandle, SSDFunctionHandle)

k = ceil(log(1 - P) / log(1 - p^n)); % calculate number of loops
numPoints = size(data, 1); %data size
bestNumInliers = 0;
bestSet = [];

for i = 1:k
    set = 1:numPoints; % create set of all possible points
    sampleIndicies = randperm(numPoints, n);
    %set(sampleIndicies) = []; % remove samples from set
    
    samples = data(sampleIndicies,:,:);
    setting = settingFunctionHandle(samples(:,:,1), samples(:,:,2)); % get current settings
    
    % loop over the rest to find inliers
    remaining = set;
    numInliers = 0;
    for j = remaining
        SSD = SSDFunctionHandle(data(j,:,:), setting);
        
        if SSD < epsilon
            numInliers = numInliers + 1;
        else % not inlier, remove from set
            set(set == j) = [];
        end
    end
    
    % check if new best
    if numInliers > bestNumInliers
        bestSet = set;
        bestNumInliers = numInliers;
    end
end

% compute setting for best set
bestData = data(bestSet,:,:);
bestSetting = settingFunctionHandle(bestData(:,:,1), bestData(:,:,2)); % get best settings using all inliers

end