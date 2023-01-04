function [MJDN] = ymd2mjdn(YYYY,MM,DD)
%YMD2MJDN Número de día juliano modificado a partir de una fecha dada
% Calcula el número de día juliano modificado correpondiente a una fecha entre 
% el 1900 y el 2100. Basado en la Ecuación 5.48 [Curtis]
% 
% ARGUMENTOS:
%	YYYY	- Año
%	MM		- Mes
%	DD		- Día
% 
% DEVOLUCIÓN:
%	MJDN	- Día juliano modificado

MJDN =	367*YYYY ...
		- fix(7*(YYYY + fix((MM + 9)/12))/4) ...
		+ fix(275*MM/9) ...
		+ DD ...
		+ 1721013.5 ...
		- 2400000.5;
	
end
