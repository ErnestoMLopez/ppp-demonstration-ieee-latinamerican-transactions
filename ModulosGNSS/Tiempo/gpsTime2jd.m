function JD = gpsTime2jd(tgps)
%GPSTIME2JD Fecha juliana a partir de tiempo GPS
% Calcula la fecha juliana (en escala de tiempo GPS) a partir del tiempo GPS, es
% decir que no quita los leap seconds.
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCIÓN:
%	JD		- Fecha juliana GPS (Julian date, número fraccional!)

% La fecha juliana se calcula pasando el tiempo GPS a días y agregando la fecha
% juliana correspondiente al 06/01/1980-00:00:00

SECONDS_IN_DAY = 24*60*60;

JD = (tgps/SECONDS_IN_DAY) + 2444244.5;

end