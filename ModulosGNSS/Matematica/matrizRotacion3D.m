function MCD = matrizRotacion3D(ang1,ang2,ang3,eje1,eje2,eje3,deg_rad)
%MATRIZROTACION3D Obtiene la MCD a partir de una secuencia de rotaciones
% Permite el c�lculo de la MCD en base a una secuencia de �ngulos (positivos en 
% sentido antihorario) y de ejes de rotaci�n de la terna de vectores del marco 
% de referencia original S. Esta matriz permite representar un cambio de 
% coordenadas de un  sistema S a uno S':
% 
%	v_S' = MCD*v_S
% 
% o bien una rotaci�n de un vector expresado en un marco de referencia S:
% 
%	w_S = MCD'*v_S
% 
% donde MCD est� dada por la secuencia de matrices de rotaci�n (no MCD!, es por 
% esto que la rotaci�n de un vector se logra mediante la traspuesta)
% 
%	MCD = R_C(-c)*R_B(-b)*R_A(-a)
% 
% ARGUMENTOS:
%	a,b,c	- Serie de �ngulos de rotaci�n [�]
%	A,B,C	- Secuencia de ejes en los que se lleva a cabo la rotaci�n
%	degrad	- Variable para indicar si los �ngulos est�n en grados (0, default) 
%			o radianes (1).
% 
% DEVOLUCI�N:
%	MCD		- Matriz de cosenos directores resultante

% Si no se especifica se asumen �ngulos en grados
if nargin == 6
	deg_rad = false;
end


R = zeros(3,3,3);

if deg_rad
	ang = rad2deg([ang1,ang2,ang3]);
else
	ang = [ang1,ang2,ang3];
end

sec = [eje1,eje2,eje3];

for ii = 1:3
	
	cang = cosd(ang(ii));
	sang = sind(ang(ii));
	
	switch sec(ii)
		case 1
			R(:,:,ii) = [1,		0,		0; ...
						 0,	  cang,	 sang; ...
						 0,  -sang,	 cang];
		case 2
			R(:,:,ii) = [cang,	0,	-sang; ...
							0,	1,		0; ...
						 sang,	0,	 cang];
		case 3
			R(:,:,ii) = [ cang,  sang,	0; ...
						 -sang,	 cang,	0; ...
							 0,		0,	1];
	end
	
end

MCD = R(:,:,3)*R(:,:,2)*R(:,:,1);

end