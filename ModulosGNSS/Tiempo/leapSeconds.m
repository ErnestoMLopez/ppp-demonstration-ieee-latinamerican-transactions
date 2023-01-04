function [LS] = leapSeconds(JD)
%LEAPSECONDS Determina los leaps seconds entre tiempo GPS y UTC 
%   A partir de una tabla devuelve el número de segundos entre los tiempos
%   GPS y UTC, pasandole como argumento la fecha juliana
% 
%		LS = t_GPS - t_UTC
% 
% ARGUMENTOS:
%	JD		- Fecha juliana
% 
% DEVOLUCIÓN:
%	LS		- Leap seconds [s]

if JD < 0.0
	error('Dia juliano erroneo');
end


% GPS inicia:	1980 JAN  1

if JD < 2444786.5000		% 1981 JUL  1
	LS = 0;
elseif JD < 2445151.5000	% 1982 JUL  1
	LS = 1;
elseif JD < 2445516.5000	% 1983 JUL  1
	LS = 2;
elseif JD < 2446247.5000	% 1985 JUL  1
	LS = 3;
elseif JD < 2447161.5000	% 1988 JAN  1
	LS = 4;
elseif JD < 2447892.5000	% 1990 JAN  1
	LS = 5;
elseif JD < 2448257.5000	% 1991 JAN  1
	LS = 6;
elseif JD < 2448804.5000	% 1992 JUL  1
	LS = 7;
elseif JD < 2449169.5000	% 1993 JUL  1
	LS = 8;
elseif JD < 2449534.5000	% 1994 JUL  1
	LS = 9;
elseif JD < 2450083.5000	% 1996 JAN  1
	LS = 10;
elseif JD < 2450630.5000	% 1997 JUL  1
	LS = 11;
elseif JD < 2451179.5000	% 1999 JAN  1
	LS = 12;
elseif JD < 2453736.5000	% 2006 JAN  1
	LS = 13;	
elseif JD < 2454832.5000	% 2009 JAN  1
	LS = 14;
elseif JD < 2456109.5000	% 2012 JUL  1
	LS = 15;
elseif JD < 2457204.5000	% 2015 JUL  1
	LS = 16;
elseif JD < 2457754.5000	% 2017 JAN  1
	LS = 17;
else
	LS = 18;
end
	
	
end

