f=595;
k1=-0;
k2=0;
loop=0;
matchExp=0;
blend='NoBlend';

path='imgs';
datasets={'ucsb4','family_house','glacier4'};

fNames=dir(['./',path,'/',datasets{1},'/*.jpg']);
fNames={fNames.name};
run('lib/vlfeat-0.9.20/toolbox/vl_setup');
% get filenames
size = length(fNames);
files = cell([1 size]);
for i = 1:size
    files(i) = fullfile(['./',path,'/',datasets{1}], fNames(i));
end
files = fliplr(files)
imgs = loadImages(files);

panorama=createPanoramaCyl( imgs, f, k1, k2, loop, matchExp, blend );
imshow(panorama);