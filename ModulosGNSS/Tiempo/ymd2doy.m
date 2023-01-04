function DOY = ymd2doy(YYYY,MM,DD)
%YMD2DOY D�a del a�o a partir de a�o, mes y d�a
% Calcula el d�a del a�o que corresponde a una fecha dada.
% 
% ARGUMENTOS:
%	YYYY 	- A�o
% 	MM 		- Mes
% 	DD 		- D�a
% 
% DEVOLUCI�N:
%	DOY		- D�a del a�o 

JD	= ymdhms2jd(YYYY,MM,DD,00,00,00);
JD0 = ymdhms2jd(YYYY,01,01,00,00,00);

DOY = 1 + fix(JD - JD0);	
	
end