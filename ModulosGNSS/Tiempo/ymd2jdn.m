function [JDN] = ymd2jdn(YYYY,MM,DD)
%YMD2JDN N�mero de d�a Juliano a partir de una fecha
% Convierte un d�a (hora 0 UT) al n�mero de d�a Juliano correspondiente. V�lido
% para cualquier fecha entre 1900 y 2100.
% 
% ARGUMENTOS:
%	YYYY	- A�o
%	MM		- Mes
%	DD		- D�a
% 
% DEVOLUCI�N:
%	JDN		- D�a Juliano (Julian day number, n�mero entero!)

JDN =	367*YYYY ...
		- fix(7*(YYYY + fix((MM + 9)/12))/4) ...
		+ fix(275*MM/9) ...
		+ DD ...
		+ 1721013.5;

end

