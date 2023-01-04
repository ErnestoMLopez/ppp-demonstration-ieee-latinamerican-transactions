function [hh,mm,ss] = sod2hms(ss)
%SOD2HMS Convierte los segundos del día en horas, minutos y segundos
%
% ARGUMENTOS:
%	sod -	Segundos del día a convertir
%
% DEVOLUCION:
%	hh	- Hora del día
%	mm	- Minutos de la hora
%	ss	- Segundos del minuto

mm = ss/60;
hh = fix(mm/60);
mm = fix(mm - 60*hh);
ss = ss-3600*hh-60*mm;

end

