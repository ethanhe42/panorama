function [sorted_imgs]=imorder(imgs)
Thresh = 5;
confidence = 0.999;
inlierRatio = 0.1;
epsilon = 1.5;

nImgs = size(imgs, 4);

T = zeros(3, 3, nImgs);
T(:, :, 1) = eye(3);
imgs_feat{nImgs}={};
imgs_dist{nImgs}={};
for i=1: nImgs
    [f, d] = getSIFTFeatures(imgs(:, :, :, i), Thresh);
    imgs_feat{i}=f;
    imgs_dist{i}=d;
end
ifmatch=zeros(nImgs,nImgs);
transforms{nImgs,nImgs}={};
for i = 1 : nImgs
    for j = 1 : nImgs
        if j==i
            continue
        end
        [matches, ~] = getMatches(imgs_feat{i}, imgs_dist{i},...
            imgs_feat{j}, imgs_dist{j});
        [T,nInliers] = ...
        RANSAC(confidence, inlierRatio, 1, matches, epsilon);
        if nInliers>5.9+.22*length(matches)
            ifmatch(i,j)=1;
            transforms{i,j}=T;
        end
    end
end
sequence=[];
sequence(1)=1;
%% forward matching
for i=2:nImgs
    nextIdx=find(ifmatch(sequence(i-1),:)==1);
    if size(nextIdx,2)==0
        break
    end
    failed=true;
    for matched=1:size(nextIdx,2)
        if size(find(sequence==nextIdx(matched)),2)==1
            continue
        end
        real_idx=matched;
        failed=false;
        break
    end
    
	if failed==false
        sequence(i)=nextIdx(real_idx);
    else
        break
    end
end
%% backward matching
for i=2:nImgs
    nextIdx=find(ifmatch(sequence(1),:)==1);
    if size(nextIdx,2)==0
        break
    end
    failed=true;
    for matched=1:size(nextIdx,2)
        if size(find(sequence==nextIdx(matched)),2)==1
            continue
        end
        real_idx=matched;
        failed=false;
        break
    end
    if failed==false
        sequence=[nextIdx(real_idx),sequence];
    else
        break
    end
end
%% reorder
disp(['using ',int2str(length(sequence)),' of ',int2str(length(imgs(1,1,1,:))),' unordered imgs']);
sorted_imgs=zeros(size(imgs,1),size(imgs,2),size(imgs,3),length(sequence),'like',imgs);
for i=1:length(sequence)
    sorted_imgs(:,:,:,i)=imgs(:,:,:,sequence(i));
end


