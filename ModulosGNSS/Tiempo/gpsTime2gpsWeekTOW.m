function [GPSweek,GPStow] = gpsTime2gpsWeekTOW(tgps)
%GPSTIME2GPSWEEKTOW Semana y segundos de la semana a partir de tiempo GPS
%
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
%
% DEVOLUCI�N:
%	GPSweek - N�mero de semana GPS (NO en m�dulo 1024)
%	GPStow	- Segundos de la semana (Time of week)

SECONDS_IN_WEEK = 7*24*60*60;

GPSweek = fix(tgps/SECONDS_IN_WEEK);
GPStow = tgps - GPSweek*SECONDS_IN_WEEK;

end