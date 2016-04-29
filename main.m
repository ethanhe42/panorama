clear all
%% params

k1=-0;
k2=0;

which=11;
path='imgs';

%%
%             1       2bad          3           4             5
datasets={'ucsb4','family_house','glacier4','yellowstone2','GrandCanyon1',...
    'yellowstone5','yellowstone4','west_campus1','redrock','intersection',...
...%     6              7               8             9failed    10failed
'GrandCanyon2'};
% 11  failed

focus=[595,400,2000,1000,1000,1000,1000,1000,1000,1000,1000];
Full360=[0,1,0,0,0,0,0,0,1000,1000,1000];
full=Full360(which);
f=focus(which);
run('lib/vlfeat-0.9.20/toolbox/vl_setup');

s=imageSet(fullfile(path,datasets{which}));
img=read(s,1);
imgs=zeros(size(img,1),size(img,2),size(img,3),s.Count,'like',img);
for i=1:s.Count
    imgs(:,:,:,i)=read(s,i);
end

panorama=create( imgs, f, full);
imwrite(panorama,['./results/',datasets{which},'.jpg']);