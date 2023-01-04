function [dr] = enu2ecefdif(drENU,r0)
%ENU2ECEFDIF Diferencia ECEF de una posici�n local ENU respecto a otra en ECEF
%   Calcula las coordenadas ECEF de un punto dado como un desplazamiento en el 
%	marco local East, North, Up respecto a una posici�n referencia dada en el
%	marco ECEF
% 
% ARGUMENTOS:
%	drENU (3x1)	- Vector diferencia de posici�n ENU [m]
%	r0 (3x1)	- Vector posici�n ECEF del punto de referencia 
% 
% DEVOLUCION:
%	dr (3x1)	- Vector diferencia de posici�n ECEF [m]

	
% Convierto el punto de referencia a coordenadas geod�sicas
[lla0] = ecef2llaGeod(r0);

lat0 = lla0(1);
lon0 = lla0(2);


% Matriz de rotaci�n del marco ECEF al ENU
R = [-sind(lon0)			 cosd(lon0)				0; ...
	-cosd(lon0)*sind(lat0)	-sind(lon0)*sind(lat0)	cosd(lat0); ...
	cosd(lon0)*cosd(lat0)	 sind(lon0)*cosd(lat0)	sind(lat0)];

% Roto al marco ECEF
dr = R.'*drENU;

end