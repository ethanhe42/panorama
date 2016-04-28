%% Ke Ma, Christopher Bodden
% CS 766 - Project 2

%% simple callback for enlarging graphs/images
function enlargeImage(handles, falseColor)
im = get( gcbo,'cdata' );
imtool(im, [min(im(:)) max(im(:))] )

if exist('falseColor')
    colormap(jet(256));
end
end