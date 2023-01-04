function [JDN] = ymd2jdn(YYYY,MM,DD)
%YMD2JDN Número de día Juliano a partir de una fecha
% Convierte un día (hora 0 UT) al número de día Juliano correspondiente. Válido
% para cualquier fecha entre 1900 y 2100.
% 
% ARGUMENTOS:
%	YYYY	- Año
%	MM		- Mes
%	DD		- Día
% 
% DEVOLUCIÓN:
%	JDN		- Día Juliano (Julian day number, número entero!)

JDN =	367*YYYY ...
		- fix(7*(YYYY + fix((MM + 9)/12))/4) ...
		+ fix(275*MM/9) ...
		+ DD ...
		+ 1721013.5;

end

