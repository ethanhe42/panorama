function [potential_matches, scores] = getMatches(f1, d1, f2, d2)

[matches, scores] = vl_ubcmatch(d1, d2);

numMatches = size(matches,2);
pairs = nan(numMatches, 3, 2);
pairs(:,:,1)=[f1(2,matches(1,:));f1(1,matches(1,:));ones(1,numMatches)]';
pairs(:,:,2)=[f2(2,matches(2,:));f2(1,matches(2,:));ones(1,numMatches)]';

potential_matches = pairs;

end
