function [tgps] = utcTime2gpsTime(YYYY,MM,DD,hh,mm,ss)
%UTCTIME2GPSTIME Tiempo GPS a partir de un tiempo UTC
%	Los argumentos de entrada son los correspondientes al tiempo UTC, son
%	convertidos a la fecha juliana y este luego al formato GPS. Finalmente se
%	le agregan los leap seconds que correspondan a la fecha.
%
%	Tiempo GPS: segundos desde el 06/01/1980-00:00:00
% 
% ARGUMENTOS:
%	YYYY	- Año UTC
%	MM		- Mes UTC
%	DD		- Día UTC
%	hh		- Hora UTC
%	mm		- Minuto UTC
%	ss		- Segundo UTC
% 
% DEVOLUCIÓN:
%	tgps	- Tiempo GPS [s]

SECONDS_IN_DAY = 24*60*60;

if nargin == 4
	mm = 0;
	ss = 0;
end;


JD = ymdhms2jd(YYYY,MM,DD,hh,mm,ss);

% Antes de convertir debo agregar los leap seconds
LS = leapSeconds(JD);
JDgps = JD + LS/SECONDS_IN_DAY;

tgps = jd2gpsTime(JDgps);

% Si la fecha UTC era con un segundo entero redondeo para evitar errores
% numéricos
if mod(ss,round(ss)) == 0
	tgps = round(tgps);
end

end