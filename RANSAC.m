function [bestSetting] = RANSAC(confidence, inliner_Ratio, Npairs, data, epsilon, settingFunctionHandle, SSDFunctionHandle)

m = ceil(log(1 - confidence) / log(1 - inliner_Ratio^Npairs)); % calculate number of loops
numPoints = size(data, 1); %data size
bestNumInliers = 0;
bestSet = [];

for i = 1:m
    set = 1:numPoints; % create set of all possible points
    sampleIndicies = randperm(numPoints, Npairs);
    
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

% use inliers to recompute transform
bestData = data(bestSet,:,:);
bestSetting = settingFunctionHandle(bestData(:,:,1), bestData(:,:,2)); % get best settings using all inliers

end