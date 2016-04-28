%% compute translation matrix
%  input:   cp1 - correspondence points in image1, n x 2 matrix
%           cp2 - correspondence points in image2, n x 2 matrix
%  output:  H - translation matrix that transforms points in image2
%               to points in image1, 3 x 3 matrix
%  if overdetermined, solve in the least-sqaure sense
function [ T ] = solveTranslation( cp1, cp2 )

n = size(cp1,1);
A = zeros(2*n, 2);
b = zeros(2*n, 1);
for i = 1:n
    A(2*i-1,1) = 1;
    b(2*i-1) = cp1(i,1)-cp2(i,1);
    A(2*i,2) = 1;
    b(2*i) = cp1(i,2)-cp2(i,2);
end
t = A \ b;
T = [1 0 t(1); 0 1 t(2); 0 0 1];

end

