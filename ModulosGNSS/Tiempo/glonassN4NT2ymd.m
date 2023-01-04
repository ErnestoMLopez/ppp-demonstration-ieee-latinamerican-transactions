function [YYYY,MM,DD] = glonassN4NT2ymd(N4,NT)
%GLONASSNT2YMD A�o, mes y d�a a partir de par�metros de efem�rides GLONASS
% Este c�digo est� basado en el Ap�ndice 3.1.3 del ICD de GLONASS
% 
% ARGUMENTOS:
%	NT	- Par�metro NT del mensaje de navegaci�n de GLONASS
%	N4	- Par�metro N4 del almanaque de GLONASS, n�mero de intervalo de 4 a�os 
%		desde el 1996 en la presente �poca, 
% 		i.e. 1996-2000 -> 1
%			 2000-2004 -> 2
%			 2004-2008 -> 3 ...
% 
% DEVOLUCI�N:
%	YYYY	- A�o de la presente efem�ride
% 
% 
% AUTOR: Ernesto Mauro L�pez
% FECHA: 22/03/2019

if (NT >= 1) && (NT <= 366)
	J = 1;
elseif (NT >= 367) && (NT <= 731)
	J = 2;
elseif (NT >= 732) && (NT <= 1096)
	J = 3;
elseif (NT >= 1097) && (NT <= 1461)
	J = 4;
end

YYYY = 1996 + 4*(N4-1) + (J-1);

if J == 1
	DOY = NT;
else
	DOY = NT - (J-1)*365 - 1;
end

[DD,MM] = doy2daymonth(YYYY,DOY);

end
