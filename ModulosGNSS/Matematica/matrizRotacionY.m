function Ry = matrizRotacionY(theta,degrad)
%MATRIZROTACIONY Obtiene la matriz de rotación (MCD) sobre el eje Y
% Esta función obtiene la matriz de cosenos directores para una rotación sobre l
% eje Y. Esta permite la transformación de un vector en el marco de referencia
% original al rotado. Para rotar un vector en el mismo marco de referencia
% entonces debe usarse la traspuesta de esta matriz.
% 
% ARGUMENTOS:
%	theta	- Ángulo de rotación en sentido antihorario [º]
%	degrad	- Variable para indicar si los ángulos están en grados (0, default) 
%			o radianes (1).
% 
% DEVOLUCIÓN:
%	Ry		- Matriz de rotación

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

