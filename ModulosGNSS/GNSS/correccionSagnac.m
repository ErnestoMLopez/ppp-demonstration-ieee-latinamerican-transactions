function rj = correccionSagnac(rj,t_viaje)
%CORRECCIONSAGNAC Corrige el efecto Sagnac sobre la posici�n de sat�lites
% Calcula la posici�n de un sat�lite en el marco ECEF correspondiente al tiempo 
% de recepci�n a partir de su posici�n en el marco ECEF en el tiempo de 
% transmisi�n y el tiempo de viaje de la se�al, realizando la rotaci�n por la 
% rotaci�n terrestre
% 
% ARGUMENTOS:
%	rj (3x1)	- Posici�n de un sat�lite GNSS en el marco ECEF del tiempo
%				de transmisi�n [m]
%	t_viaje		- Tiempo de viaje de la se�al correspondiente a dicho sat. [s]
% 
% DEVOLUCI�N:
%	rj (3x1)	- Posici�n del sat�lite GNSS en el marco ECEF del tiempo
%				de recepci�n [m]


WE = 7.2921151467e-5;	% Velocidad de rotaci�n de la Tierra


phi = WE*t_viaje;
matrizCorrSagnac = [ cos(phi)	sin(phi)	0; ...
					-sin(phi)	cos(phi)	0; ...
					0			0			1];

rj = matrizCorrSagnac*rj;

end

