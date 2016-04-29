function [ newImg ] = merge( imgs, transforms, newHeight, newWidth ,f)
imgs=im2double(imgs);
height = size(imgs, 1);
width = size(imgs, 2);
nChannels = size(imgs, 3);
nImgs = size(imgs, 4);

mask = ones(height, width);
mask = warp(mask, f);
mask = imcomplement(mask);
mask = bwdist(mask, 'euclidean');

mask = mask ./ max(max(mask));
m=ones([height,width,nChannels],'like',imgs);
for i=1:nChannels
    m(:,:,i)=mask;
end
mask=m;

% image merging
newImg = zeros([newHeight+100 newWidth+100 nChannels], 'like',imgs);
denominator = zeros([newHeight+100 newWidth+100 nChannels], 'like',imgs);
for i=1:nImgs
    p_prime=transforms(:,:,i)*[1;1;1];
    p_prime=p_prime./p_prime(3);
    base_h=floor(p_prime(1));
    base_w=floor(p_prime(2));
    if base_h==0
        base_h=1;
    end
    if base_w==0
        base_w=1;
    end

    newImg(base_h:base_h+height-1,base_w:base_w+width-1,:)=...
        newImg(base_h:base_h+height-1,base_w:base_w+width-1,:)+...
        imgs(:,:,:,i).*mask;
    denominator(base_h:base_h+height-1,base_w:base_w+width-1,:)=...
        denominator(base_h:base_h+height-1,base_w:base_w+width-1,:)+...
        mask;
end

newImg=newImg./denominator;
end
