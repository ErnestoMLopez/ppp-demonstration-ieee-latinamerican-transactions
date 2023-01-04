function [ss] = hms2sod(hh,mm,ss)
%SOD2HMS Convierte horas, minutos y segundos en segundos del día
%
% ARGUMENTOS:
%	hh	- Hora del día a convertir
%	mm	- Minutos de la hora a convertir
%	ss	- Segundos del minuto a convertir
%
% DEVOLUCION:
%	sod -	Segundos del día

ss = 3600*hh + 60*mm + ss;

end

