function [enu] = ecefdif2enu(r,r0)
%ECEFDIF2ENU Coordendas locales ENU de posiciones ECEF respecto a otra
%   Calcula las coordenadas locales East, North, Up de un punto en 
%	coordenadas ECEF observado desde otro punto también en coordenadas ECEF
% 
% ARGUMENTOS:
%	r (3x1)		- Vector posición ECEF [m]
%	r0 (3x1)	- Vector posición ECEF del punto de referencia 
% 
% DEVOLUCION:
%	enu (3x1)	- Coordenadas locales de la posición [m]

	
% Convierto el punto de referencia a coordenadas geodésicas
[lla0] = ecef2llaGeod(r0);

lat0 = lla0(1);
lon0 = lla0(2);
% 	alt0 = lla0(3);


% Matriz de rotación del marco ECEF al ENU
R = [-sind(lon0)			 cosd(lon0)				0; ...
	-cosd(lon0)*sind(lat0)	-sind(lon0)*sind(lat0)	cosd(lat0); ...
	cosd(lon0)*cosd(lat0)	 sind(lon0)*cosd(lat0)	sind(lat0)];

% Armo los vectores línea de visión de cada época
ldv = r - r0;

% Roto al marco
enu = R*ldv;

end