function [MJDN] = ymd2mjdn(YYYY,MM,DD)
%YMD2MJDN N�mero de d�a juliano modificado a partir de una fecha dada
% Calcula el n�mero de d�a juliano modificado correpondiente a una fecha entre 
% el 1900 y el 2100. Basado en la Ecuaci�n 5.48 [Curtis]
% 
% ARGUMENTOS:
%	YYYY	- A�o
%	MM		- Mes
%	DD		- D�a
% 
% DEVOLUCI�N:
%	MJDN	- D�a juliano modificado

MJDN =	367*YYYY ...
		- fix(7*(YYYY + fix((MM + 9)/12))/4) ...
		+ fix(275*MM/9) ...
		+ DD ...
		+ 1721013.5 ...
		- 2400000.5;
	
end
