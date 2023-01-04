function [YYYY,MM,DD,hh,mm,ss] = gpsTime2ymdhms(tgps)
%GPSTIME2YMDHMS Convierte un tiempo GPS a formato fecha
% Convierte un tiempo GPS expresado en segundos a un formato fecha SIN leap
% seconds (mantiene la escala).
% 
%	Tiempo GPS: segundos desde el 06/01/1980-00:00:00
% 
% ARGUMENTOS:
%	tgps	- Tiempo GPS [s]
% 
% DEVOLUCIÓN:
%	YYYY	- Año GPS
%	MM		- Mes GPS
%	DD		- Día GPS
%	hh		- Hora GPS
%	mm		- Minuto GPS
%	ss		- Segundo GPS

% Separo en parte entera y parte fraccional
tgps_int = fix(tgps);
tgps_frac = tgps - tgps_int;

JD = gpsTime2jd(tgps_int);

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