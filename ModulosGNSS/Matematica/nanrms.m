function y = nanrms(x, dim)
%RMS    Root mean squared value, ignoring NaNs
%	Función de Matlab modificada para poder omitir facilmente NaNs sin tener que
%	especificarlo como parámetro. La función RMS del Signal Processing Toolbox
%	no trae esta opción incluida. Modificarla para agregarle el parámetro
%	implicaría el chqueo de cantidad de variables, del string para levantar
%	flag, etc., por lo que simplemente se crea una función que emula a nanmean,
%	nanstd y nanvar.
% 
%   For vectors, RMS(X) is the root mean squared value in X. For matrices,
%   RMS(X) is a row vector containing the RMS value from each column. For
%   N-D arrays, RMS(X) operates along the first non-singleton dimension.
%
%   Y = RMS(X,DIM) operates along the dimension DIM.
%
%   When X is complex, the RMS is computed using the magnitude
%   RMS(ABS(X)). 
%
%   % Example #1: RMS of sinusoid vector 
%   x = cos(2*pi*(1:100)/100);
%   y = rms(x)
%
%   % Example #2: RMS of columns of matrix
%   x = [rand(100000,1) randn(100000,1)]; 
%   y = rms(x, 1)  
%
%   % Example #3: RMS of rows of matrix
%   x = [2 -2 2; 3 3 -3]; 
%   y = rms(x, 2)  
%
%   See also MIN, MAX, MEDIAN, MEAN, STD, PEAK2RMS.

%   Copyright 2011 The MathWorks, Inc.
%#codegen

if nargin==1
  y = sqrt(mean(x .* conj(x), 'omitnan'));
else
  y = sqrt(mean(x .* conj(x), dim, 'omitnan'));
end

