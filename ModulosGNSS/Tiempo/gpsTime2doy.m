function DOY = gpsTime2doy(tgps)
%GPSTIME2DOY D�a del a�o a partir de tiempo GPS
% Calcula el d�a del a�o que corresponde a un tiempo GPS en segundos.
% Tiempo GPS: segundos desde el 06/01/1980-00:00:00
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCI�N:
%	DOY		- D�a del a�o 

[YY,MM,DD,hh,mm,ss] = gpsTime2ymdhms(tgps);

JD	= ymdhms2jd(YY,MM,DD,hh,mm,ss);
JD0 = ymdhms2jd(YY,01,01,00,00,00);

DOY = 1 + fix(JD - JD0);	
	
end