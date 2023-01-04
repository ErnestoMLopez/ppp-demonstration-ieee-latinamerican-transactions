function [JD] = ymdhms2jd(YYYY,MM,DD,hh,mm,ss)
%YMDHMS2JD Fecha Juliana a partir de un tiempo en formato fecha
% Convierte una fecha a la fecha juliana correspondiente. La escala de tiempo no
% importa, puede ser GPS, UTC o la que fuere, aunque es usual que sea UTC o UT.
% 
% ARGUMENTOS:
%	YYYY	- Año
%	MM		- Mes
%	DD		- Día
%	hh		- Hora
%	mm		- Minuto
%	ss		- Segundo
% 
% DEVOLUCIÓN:
%	JD		- Fecha juliana (Julian date, número fraccional!)

JDN = ymd2jdn(YYYY,MM,DD);

UT = hh/24 + mm/(24*60) + ss/(24*60*60);

JD = JDN + UT;

end

