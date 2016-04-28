%% function to compute sum of squared errors
%  input:   datapoint - 1 x n x 2 matrix containing the points to compare (1 x n vectors) 
%           transform - the nxn transform to apply to pprime
%  output:  SSR - calculation of sum of squared errors
function [SSR] = compError(datapoint, transform)
    p_prime = transform * datapoint(1,:,2)';
    p_prime = (p_prime ./ p_prime(3)); % convert to non-homogeneous coords
    p = datapoint(1,:,1)';
    error = p - p_prime;
    sqauredError = error .^ 2;
    SSR = sum(sqauredError);
end