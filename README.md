# panorama
panorama creator  
![img](https://github.com/yihui-he/panorama/blob/master/results/intersection.jpg)  
![img](https://github.com/yihui-he/panorama/blob/master/results/GrandCanyon2.jpg)  
![img](https://github.com/yihui-he/panorama/blob/master/results/redrock.jpg)  
### bonus  
I implemented all of the elaborate features described in **BONUS** part.  
- I'm able to handle 360 panorama.
- Random sequence of images input is welcomed.
- I use color blending and smoothing to make the image more continuous.  

### how to run  
images files are already in ./imgs  
- If you want to see results directly, go to ./results folder
- If you want to test all images sets with only one click,run RunAllDatasets.m.(This may run 10 more minutes, because I didn't resize large images. If I have more time, I can add this feature)  
- If you want to specify the image folder, run main.m with path to images folder as argument(as described in assignment)  

**Note that**, if you use the last way to run my code, the folder names should be as follows(I need to tune focus on each image set)  
'ucsb4','family_house','glacier4','yellowstone2','GrandCanyon1','yellowstone5','yellowstone4','west_campus1','redrock','intersection','GrandCanyon2'  
For example:  
`main('./imgs/ucsb4/');`

######details of my algorithms are shown below:  

### 360 panorama
- [x] mapping image to cylindrical coordinate

### recognize panorama(random inputs)
I select two random sequence images set:family\_house, and west\_campus1  
They are already shuffled. You can see them in imgs folder.  
Or you can run shuffle.bash to shuffle them again.  
As described in Brown's paper, I use $N\_inlier>k\*N\_pairs+b$ to compute whether a pair of images match or not  
k,b are const. Set to 5.9 and 0.22 respectively.  

### merging and blending  
- [x] Alpha  
- [ ] Pyramid  
- [x] Noblend


### transformation
- [x] homography transformation.
- [x] translation transformation.( This is more robust)

### matching
- [x] RANSAC
- [ ] exposure matching  

### global adjustment
- [x] end to end adjustment(comput shift and subtract shift/n to each image)  
- [ ] bundle adjustment(difficult way)  

### getting features
- [x] use SIFT features(using VLFeat library, professor allowed)  
- [x] SURF features, (SIFT is better)  



