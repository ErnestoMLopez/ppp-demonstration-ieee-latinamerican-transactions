function [aer] = enu2aer(drENU)
%ENU2AER Azimut, elevación y rango a partir de posición local ENU
%   Calcula el azimut, elevación y rango de un punto en coordenadas locales ENU
% 
% ARGUMENTOS:
%	drENU (3x1)	- Vector posición local ENU [m]
% 
% DEVOLUCION:
%	aer (3x1)	- Coordenadas horizontales locales de la posición [º], [º] y [m]

east = drENU(1);
north = drENU(2);
up = drENU(3);


ran = sqrt(east.^2 + north.^2 + up.^2);

azi = atan2d(east,north);

% El azimut se expresa de 0º a 360º desde el norte en sentido horario
if azi < 0
	azi = azi + 360;
end

ele = atan2d(up,sqrt(east.^2 + north.^2));


aer = [azi; ele; ran];

end

