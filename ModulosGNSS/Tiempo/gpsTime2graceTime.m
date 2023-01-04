function [tgrace] = gpsTime2graceTime(tgps)
%GPSTIME2GRACETIME Tiempo GRACE a partir de tiempo GPS
%	Los tiempos de recepción GRACE son dados en escala de tiempo GPS en forma de
%	segundos trasncurridos desde la época 2000-01-01 12:00:00, correspondiente 
%	al tiempo GPS 630763200 (WEEK:TOW 1042:561600)
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCIÓN:
%	tgrace	- Tiempo GRACE [s]

epoca0 = ymdhms2gpsTime(2000,01,01,12,00,00);

tgrace = tgps - epoca0;

end