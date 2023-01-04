function Ry = matrizRotacionY(theta,degrad)
%MATRIZROTACIONY Obtiene la matriz de rotaci�n (MCD) sobre el eje Y
% Esta funci�n obtiene la matriz de cosenos directores para una rotaci�n sobre l
% eje Y. Esta permite la transformaci�n de un vector en el marco de referencia
% original al rotado. Para rotar un vector en el mismo marco de referencia
% entonces debe usarse la traspuesta de esta matriz.
% 
% ARGUMENTOS:
%	theta	- �ngulo de rotaci�n en sentido antihorario [�]
%	degrad	- Variable para indicar si los �ngulos est�n en grados (0, default) 
%			o radianes (1).
% 
% DEVOLUCI�N:
%	Ry		- Matriz de rotaci�n

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

Ry = [cang,		0,	-sang; ...
		 0,		1,		0; ...
	  sang,		0,	 cang];
 
end

