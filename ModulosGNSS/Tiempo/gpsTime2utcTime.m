function [YYYY,MM,DD,hh,mm,ss] = gpsTime2utcTime(tgps)
%GPSTIME2UTCTIME Fecha y hora UTC a partir de tiempo GPS
%   Calcula la fecha y hora UTC a partir del tiempo GPS en segundos, quitando
%	los correspondientes leap seconds.
%
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
%
% DEVOLUCIÓN:
%	YYYY	- Año UTC
%	MM		- Mes UTC
%	DD		- Día UTC
%	hh		- Hora UTC
%	mm		- Minuto UTC
%	ss		- Segundo UTC

SECONDS_IN_DAY = 24*60*60;

LS = 0;

% Separo en parte entera y parte fraccional
tgps_int = fix(tgps);
tgps_frac = tgps - tgps_int;

% Calculo en forma iterativa la fecha juliana correspondiente al tiempo UTC
% restando los correspondientes leap seconds
for i = 1:10
	JD = ((tgps_int-LS)/SECONDS_IN_DAY) + 2444244.5;
	
	LS = leapSeconds(JD);
end

% Ahora que tengo la fecha juliana en tiempo UTC convierto a formato fecha
[YYYY,MM,DD,hh,mm,ss] = jd2ymdhms(JD);

% Ya que trabajé con segundos enteros redondeo para evitar errores numéricos
ss = round(ss);

% Finalmente agrego la parte fraccional
ss = ss + tgps_frac;

% Y me fijo si hubo rollover
if ss >= 60.0
	ss = ss - 60.0;
	mm = mm + 1;
	
	if mm >= 60
		mm = mm - 60;
		hh = hh + 1;
		
		if hh >= 24
			hh = hh - 24;
			DD = DD + 1;
			
			dim = daysInMonth(YYYY,MM);
			
			if DD > dim
				DD = 1;
				MM = MM + 1;
				
				if MM > 12
					MM = 1;
					YYYY = YYYY + 1;
				end
			end
		end
	end
end

end