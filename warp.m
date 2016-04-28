function [output]=warp(i,f,s)
    if f<s
        disp('focus should larger than scale')
    end
    output=i;
        
    for layer=1:length(size(i))
        x_center=size(i,2)/2;
        y_center=size(i,1)/2;
        x=(1:size(i,2))-x_center;
        y=(1:size(i,1))-y_center;
        [xx,yy]=meshgrid(x,y);
        yy=s*yy./sqrt(xx.^2+f^2)+y_center;
        xx=s*atan(xx/f)+x_center;
        xx=floor(xx+.5);
        yy=floor(yy+.5);

    %         cylinder(r,:)=...
    %         i(sub2ind(size(i), yy(r,:), x));
        idx=sub2ind([size(i,1),size(i,2)], yy, xx);

        mask=zeros([size(i,1),size(i,2)]);
        mask(idx)=i(:,:,layer);
        cylinder=i(:,:,layer);
        cylinder(idx)=i(:,:,layer);
        cylinder(mask==0)=0;
        output(:,:,layer)=cylinder;
    end
    %imshow(output);
end