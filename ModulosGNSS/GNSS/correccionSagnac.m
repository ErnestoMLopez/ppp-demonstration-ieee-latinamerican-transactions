function rj = correccionSagnac(rj,t_viaje)
%CORRECCIONSAGNAC Corrige el efecto Sagnac sobre la posición de satélites
% Calcula la posición de un satélite en el marco ECEF correspondiente al tiempo 
% de recepción a partir de su posición en el marco ECEF en el tiempo de 
% transmisión y el tiempo de viaje de la señal, realizando la rotación por la 
% rotación terrestre
% 
% ARGUMENTOS:
%	rj (3x1)	- Posición de un satélite GNSS en el marco ECEF del tiempo
%				de transmisión [m]
%	t_viaje		- Tiempo de viaje de la señal correspondiente a dicho sat. [s]
% 
% DEVOLUCIÓN:
%	rj (3x1)	- Posición del satélite GNSS en el marco ECEF del tiempo
%				de recepción [m]


WE = 7.2921151467e-5;	% Velocidad de rotación de la Tierra


phi = WE*t_viaje;
matrizCorrSagnac = [ cos(phi)	sin(phi)	0; ...
					-sin(phi)	cos(phi)	0; ...
					0			0			1];

rj = matrizCorrSagnac*rj;

end

