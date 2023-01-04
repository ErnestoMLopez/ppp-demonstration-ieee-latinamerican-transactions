function [tgps] = gpsWeekTOW2gpsTime(WWWW,TOW)
%GPSWEEKTOW2GPSTIME Tiempo GPS a partir de semana y segundos de la semana
%
% ARGUMENTOS:
%	WWWW - N�mero de semana GPS (NO en m�dulo 1024)
%	TOW	- Segundos de la semana (Time of week)
%
% DEVOLUCI�N:
%	tgps	- Tiempo GPS [s]

SECONDS_IN_WEEK = 7*24*60*60;

tgps = WWWW*SECONDS_IN_WEEK + TOW;

end