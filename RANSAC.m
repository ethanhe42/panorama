function [T,MaxInliers] = RANSAC(confidence, inliner_Ratio, Npairs, data, epsilon)

m = ceil(log(1 - confidence) / log(1 - inliner_Ratio^Npairs)); % calculate number of loops
NPoints = size(data, 1);
MaxInliers = 0;

A = zeros(2*Npairs, 2);
b = zeros(2*Npairs, 1);
for i = 1:Npairs
    A(2*i-1,1) = 1;
    A(2*i,2) = 1;
end

for i = 1:m
    sampleIndicies = randperm(NPoints, Npairs);
    
    samples = data(sampleIndicies,:,:);
    
    pair0=samples(:,:,1);
    pair1=samples(:,:,2);

    for j = 1:Npairs
        b(2*j-1) = pair0(j,1)-pair1(j,1);
        b(2*j) = pair0(j,2)-pair1(j,2);
    end
    t = A \ b;
    T = [1 0 t(1); 0 1 t(2); 0 0 1];
    
    
    p_prime = T * data(:,:,2)';
    error = data(:,:,1)' - p_prime;
    SE = error .^ 2;
    SSE = sum(SE);
    
    numInliers=sum(SSE<epsilon);
    
    % if better
    if numInliers > MaxInliers
        bestSet = find(SSE<epsilon);
        MaxInliers = numInliers;
    end
end

% use inliers to recompute transform
pair0=data(bestSet,:,1);
pair1= data(bestSet,:,2);

for j = 1:Npairs
    b(2*j-1) = pair0(j,1)-pair1(j,1);
    b(2*j) = pair0(j,2)-pair1(j,2);
end
t = A \ b;
T = [1 0 t(1); 0 1 t(2); 0 0 1];

end