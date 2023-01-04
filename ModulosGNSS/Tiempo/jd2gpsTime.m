function [tgps] = jd2gpsTime(JD)
%GPSDATE2GPSTIME Tiempo GPS a partir de una fecha juliana
% Convierte una fecha juliana EN ESCALA DE TIEMPO GPS, al tiempo GPS expresado en
% segundos.
% 
%	Tiempo GPS: segundos desde el 06/01/1980-00:00:00
% 
% ARGUMENTOS:
%	JD		- Fecha juliana (Julian date, número fraccional!)
% 
% DEVOLUCIÓN:
%	tgps	- Tiempo GPS [s]

SECONDS_IN_DAY = 24*60*60;

tgps = (JD-2444244.5)*SECONDS_IN_DAY;

end