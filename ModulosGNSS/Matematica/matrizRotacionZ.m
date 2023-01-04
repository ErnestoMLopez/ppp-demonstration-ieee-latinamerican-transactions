function Rz = matrizRotacionZ(theta,degrad)
%MATRIZROTACIONZ Obtiene la matriz de rotaci�n (MCD) sobre el eje Z
% Esta funci�n obtiene la matriz de cosenos directores para una rotaci�n sobre l
% eje Z. Esta permite la transformaci�n de un vector en el marco de referencia
% original al rotado. Para rotar un vector en el mismo marco de referencia
% entonces debe usarse la traspuesta de esta matriz.
% 
% ARGUMENTOS:
%	theta	- �ngulo de rotaci�n en sentido antihorario [�]
%	degrad	- Variable para indicar si los �ngulos est�n en grados (0, default) 
%			o radianes (1).
% 
% DEVOLUCI�N:
%	Rz		- Matriz de rotaci�n

if nargin == 1
	degrad = false;
end

if degrad
	cang = cos(theta);
	sang = sin(theta);
else
	cang = cosd(theta);
	sang = sind(theta);
end

Rz = [ cang,	 sang,	0; ...
	  -sang,	 cang,	0; ...
		  0,		0,	1];

end

