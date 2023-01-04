function [tgps] = graceTime2gpsTime(tgrace)
%GRACETIME2GPSTIME Tiempo GPS a partir de un tiempo GRACE
% Los tiempos de recepción GRACE son dados en escala de tiempo GPS en forma de
% segundos transcurridos desde la época 01/01/2000-12:00:00, correspondiente 
% al tiempo GPS 630763200 (WEEK:TOW 1042:561600). Estos entonces son convertidos
% a tiempo GPS.
% 
% ARGUMENTOS:
%	tgrace		- Tiempo GRACE [s]
% 
% DEVOLUCIÓN:
%	tgps		- Tiempo GPS [s]

epoca0 = ymdhms2gpsTime(2000,01,01,12,00,00);

tgps = epoca0 + tgrace;

end