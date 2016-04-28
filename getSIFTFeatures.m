%% function returns feature locations and SIFT descriptors for an image. Uses the VLFeat library.
%  input:   image - an rgb or greyscale image matrix
%           edgeThresh - non-edge selection threshold (default should be 10)
%  output:  potential_matches - 3 x n x 2 matrix of [x y z=1] positions for n potential feature matches in images 1 and 2
%           scores - the score for each of the n matches in a vector
function [f, d] = getSIFTFeatures(image, edgeThresh)

%convert images to greyscale
if (size(image, 3) == 3)
    Im = single(rgb2gray(image));
else
    Im = single(image);
end

% get features and descriptors
[f, d] = vl_sift(Im, 'EdgeThresh', edgeThresh);

end