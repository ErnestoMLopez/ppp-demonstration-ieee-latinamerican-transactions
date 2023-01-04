function [R] = ecef2enuMatriz(r0)
%ECEFDIF2ENU Matriz de rotaci�n al marco local ENU desde una posici�n ECEF
%   Calcula la matriz de rotaci�n necesaria para el pasaje de un marco ECEF a
%   uno local ENU
% 
% ARGUMENTOS:
%	r0 (3x1)	- Vector posici�n ECEF del punto de referencia 
% 
% DEVOLUCION:
%	R (3x3)		- Matriz de rotaci�n de ECEF a ENU


% Convierto el punto de referencia a coordenadas geod�sicas
[lla0] = ecef2llaGeod(r0);

lat0 = lla0(1);
lon0 = lla0(2);

% Matriz de rotaci�n del marco ECEF al ENU
R = [-sind(lon0)			 cosd(lon0)				0; ...
	 -cosd(lon0)*sind(lat0)	-sind(lon0)*sind(lat0)	cosd(lat0); ...
	  cosd(lon0)*cosd(lat0)	 sind(lon0)*cosd(lat0)	sind(lat0)];

end