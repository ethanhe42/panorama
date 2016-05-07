### panorama
This is my panorama creator, images files are already in ./imgs

##### bonus  
I implemented all of the elaborate features described in **BONUS** part.  
- I'm able to handle 360 panorama.
- Random sequences is ok.
- I use color blending and smoothing to make the image more continuous.  
*details of my algorithms are shown below:*  
##### getting features
- [x] use SIFT features(using VLFeat library, professor allowed)  
- [x] SURF features, (SIFT is better)  

##### 360 panorama
- [x] mapping image to cylindrical coordinate

##### transformation
- [x] homography transformation.
- [x] translation transformation.( This is more robust)

##### matching
- [x] RANSAC
- [ ] exposure matching  

##### global adjustment
- [x] end to end adjustment(comput shift and subtract shift/n to each image)  
- [ ] bundle adjustment(difficult way)  

##### merging and blending  
- [x] Alpha  
- [ ] Pyramid  
- [x] Noblend

##### recognize panorama(random inputs)
As described in Brown's paper, I use N_inlier>k\*N_pairs+b to compute whether a pair of images match or not  
k,b are const. Set to 5.9 and 0.22 respectively.  




