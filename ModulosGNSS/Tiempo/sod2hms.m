function [hh,mm,ss] = sod2hms(ss)
%SOD2HMS Convierte los segundos del d�a en horas, minutos y segundos
%
% ARGUMENTOS:
%	sod -	Segundos del d�a a convertir
%
% DEVOLUCION:
%	hh	- Hora del d�a
%	mm	- Minutos de la hora
%	ss	- Segundos del minuto

mm = ss/60;
hh = fix(mm/60);
mm = fix(mm - 60*hh);
ss = ss-3600*hh-60*mm;

end

