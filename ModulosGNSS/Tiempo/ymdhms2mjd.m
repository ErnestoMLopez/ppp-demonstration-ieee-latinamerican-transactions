function [MJD] = ymdhms2mjd(YYYY,MM,DD,hh,mm,ss)
%YMDHMS2MJD Fecha juliana modificada a partir de una fecha dada
% Calcula la fecha juliana modificada correpondiente a una fecha entre el 1900 y
% el 2100. Basado en la Ecuaci�n 5.48 [Curtis]
% 
% ARGUMENTOS:
%	YYYY	- A�o
%	MM		- Mes
%	DD		- D�a
%	hh		- Hora
%	mm		- Minuto
%	ss		- Segundo
% 
% DEVOLUCI�N:
%	MJDN	- D�a juliano modificado

MJDN =	ymd2mjdn(YYYY,MM,DD);
	
UT = hh/24 + mm/(24*60) + ss/(24*60*60);

MJD = MJDN + UT;

end
