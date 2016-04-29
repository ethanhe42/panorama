function [output]=warp(i,f)
    output=zeros(size(i),'like',i);
    if length(size(i))==2
        Layers=1;
    else
        Layers=size(i,3);
    end
    for layer=1:Layers
        x_center=size(i,2)/2;
        y_center=size(i,1)/2;
        x=(1:size(i,2))-x_center;
        y=(1:size(i,1))-y_center;
        [xx,yy]=meshgrid(x,y);
        yy=f*yy./sqrt(xx.^2+double(f)^2)+y_center;
        xx=f*atan(xx/double(f))+x_center;
        xx=floor(xx+.5);
        yy=floor(yy+.5);

        idx=sub2ind([size(i,1),size(i,2)], yy, xx);
      
        cylinder=zeros(size(i,1),size(i,2),'like',i);
        cylinder(idx)=i(:,:,layer);

        output(:,:,layer)=cylinder;
%         imshow(cylinder);
    end
end