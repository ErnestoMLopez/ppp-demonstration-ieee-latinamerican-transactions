function [YYYY,MM,DD] = glonassN4NT2ymd(N4,NT)
%GLONASSNT2YMD Año, mes y día a partir de parámetros de efemérides GLONASS
% Este código está basado en el Apéndice 3.1.3 del ICD de GLONASS
% 
% ARGUMENTOS:
%	NT	- Parámetro NT del mensaje de navegación de GLONASS
%	N4	- Parámetro N4 del almanaque de GLONASS, número de intervalo de 4 años 
%		desde el 1996 en la presente época, 
% 		i.e. 1996-2000 -> 1
%			 2000-2004 -> 2
%			 2004-2008 -> 3 ...
% 
% DEVOLUCIÓN:
%	YYYY	- Año de la presente efeméride
% 
% 
% AUTOR: Ernesto Mauro López
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
