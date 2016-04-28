%% function to return potential feature matches between two images. Uses the VLFeat library.
%  input:   f1, f2 - vector of SIFT feature locations and scales for images 1 and 2
%           d1, d2 - vector of SIFT feature descriptors that correspond
%           with f1, f2
%  output:  potential_matches - 3 x n x 2 matrix of [x y z=1] positions for n potential feature matches in images 1 and 2
%           scores - the score for each of the n matches in a vector
function [potential_matches, scores] = getPotentialMatches(f1, d1, f2, d2)

[matches, scores] = vl_ubcmatch(d1, d2);

% compute pairs
numMatches = size(matches,2);
pairs = nan(numMatches, 3, 2); % row->each match, col -> <x,y>, dim3 -> <image1,image2>
for mat = 1:numMatches
    f1_index = matches(1,mat);
    f2_index = matches(2,mat);
    
    % x y z=1
    pairs(mat,:,1) = [f1(2,f1_index) f1(1,f1_index) 1]; % img1
    pairs(mat,:,2) = [f2(2,f2_index) f2(1,f2_index) 1]; % img2
end

potential_matches = pairs;

end