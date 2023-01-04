function DOY = gpsTime2doy(tgps)
%GPSTIME2DOY Día del año a partir de tiempo GPS
% Calcula el día del año que corresponde a un tiempo GPS en segundos.
% Tiempo GPS: segundos desde el 06/01/1980-00:00:00
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCIÓN:
%	DOY		- Día del año 

[YY,MM,DD,hh,mm,ss] = gpsTime2ymdhms(tgps);

JD	= ymdhms2jd(YY,MM,DD,hh,mm,ss);
JD0 = ymdhms2jd(YY,01,01,00,00,00);

DOY = 1 + fix(JD - JD0);	
	
end