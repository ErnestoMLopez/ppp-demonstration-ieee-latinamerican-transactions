function [aer] = ecefdif2aer(r,r0)
%ECEFDIF2AER Azimut, elevaci�n y rango a partir de posiciones ECEF
%   Calcula el azimut, elevaci�n y rango de un punto en coordenadas ECEF
%   observado desde otro punto tambi�n en coordenadas ECEF
% 
% ARGUMENTOS:
%	r (3x1)		- Vector posici�n ECEF [m]
%	r0 (3x1)	- Vector posici�n ECEF del punto de referencia [m]
% 
% DEVOLUCION:
%	aer (3x1)	- Coordenadas horizontales locales de la posici�n [�], [�] y [m]


% Convierto las coordendas al marco local ENU
enu = ecefdif2enu(r,r0);

east = enu(1);
north = enu(2);
up = enu(3);


ran = sqrt(east.^2 + north.^2 + up.^2);

azi = atan2d(east,north);

% El azimut se expresa de 0� a 360� desde el norte en sentido horario
if azi < 0
	azi = azi + 360;
end

ele = atan2d(up,sqrt(east.^2 + north.^2));


aer = [azi; ele; ran];

end

