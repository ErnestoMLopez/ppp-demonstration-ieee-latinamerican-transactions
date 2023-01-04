function jd = gpsTime2utcJd(tgps)
%GPSTIME2UTCJD Fecha juliana del tiempo UTC a partir de tiempo GPS
% Calcula la fecha juliana en escala de tiempo UTC a partir del tiempo GPS, es
% decir quitando los leap seconds correspondientes.
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCIÓN:
%	JD		- Fecha juliana UTC (Julian date, número fraccional!)

% La fecha juliana se calcula restando los leap seconds, pasando el tiempo GPS a
% días y agregando la fecha juliana correspondiente al 06/01/1980-00:00:00

persistent jdprevio;
persistent tgpsprevio;

if isempty(tgpsprevio)
	tgpsprevio = 0;
end

if tgps == tgpsprevio
	jd = jdprevio;
	return;
end

SECONDS_IN_DAY = 24*60*60;

LS = 0;

% Calculo en forma iterativa la fecha juliana correspondiente al tiempo UTC
% restando los correspondientes leap seconds
for i = 1:3
	jd = ((tgps-LS)/SECONDS_IN_DAY) + 2444244.5;
	
	LS = leapSeconds(jd);
end

jdprevio = jd;
tgpsprevio = tgps;

end