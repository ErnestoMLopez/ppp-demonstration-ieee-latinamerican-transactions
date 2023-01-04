function [R] = ecef2enuMatriz(r0)
%ECEFDIF2ENU Matriz de rotación al marco local ENU desde una posición ECEF
%   Calcula la matriz de rotación necesaria para el pasaje de un marco ECEF a
%   uno local ENU
% 
% ARGUMENTOS:
%	r0 (3x1)	- Vector posición ECEF del punto de referencia 
% 
% DEVOLUCION:
%	R (3x3)		- Matriz de rotación de ECEF a ENU


% Convierto el punto de referencia a coordenadas geodésicas
[lla0] = ecef2llaGeod(r0);

lat0 = lla0(1);
lon0 = lla0(2);

% Matriz de rotación del marco ECEF al ENU
R = [-sind(lon0)			 cosd(lon0)				0; ...
	 -cosd(lon0)*sind(lat0)	-sind(lon0)*sind(lat0)	cosd(lat0); ...
	  cosd(lon0)*cosd(lat0)	 sind(lon0)*cosd(lat0)	sind(lat0)];

end