function DOY = ymd2doy(YYYY,MM,DD)
%YMD2DOY Día del año a partir de año, mes y día
% Calcula el día del año que corresponde a una fecha dada.
% 
% ARGUMENTOS:
%	YYYY 	- Año
% 	MM 		- Mes
% 	DD 		- Día
% 
% DEVOLUCIÓN:
%	DOY		- Día del año 

JD	= ymdhms2jd(YYYY,MM,DD,00,00,00);
JD0 = ymdhms2jd(YYYY,01,01,00,00,00);

DOY = 1 + fix(JD - JD0);	
	
end