%% compute homography matrix
%  input:   cp1 - correspondence points in image1, n x 2 matrix
%           cp2 - correspondence points in image2, n x 2 matrix
%  output:  H - homography matrix that transforms points in image2
%               to points in image1, 3 x 3 matrix
%  if overdetermined, solve in the least-sqaure sense
function [ H ] = solveHomography( cp1, cp2 )

n = size(cp1,1);
A = zeros(2*n, 8);
b = zeros(2*n, 1);
for i = 1:n
    A(2*i-1,1) = cp2(i,1);
    A(2*i-1,2) = cp2(i,2);
    A(2*i-1,3) = 1;
    A(2*i-1,7) = -cp1(i,1)*cp2(i,1);
    A(2*i-1,8) = -cp1(i,1)*cp2(i,2);
    b(2*i-1) = cp1(i,1);
    A(2*i,4) = cp2(i,1);
    A(2*i,5) = cp2(i,2);
    A(2*i,6) = 1;
    A(2*i,7) = -cp1(i,2)*cp2(i,1);
    A(2*i,8) = -cp1(i,2)*cp2(i,2);
    b(2*i) = cp1(i,2);
end
h = A \ b;
H = [h(1) h(2) h(3); h(4) h(5) h(6); h(7) h(8) 1];

end

