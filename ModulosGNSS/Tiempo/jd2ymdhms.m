function [YYYY,MM,DD,hh,mm,ss] = jd2ymdhms(JD)
%JD2YMDHMS Convierte la fecha Juliana al formato fecha
%   Esta función realiza solo un cambio de formato, pasando de la fecha juliana
%   a la fecha en formato YYYY,MM,DD,hh,mm,ss
% 
% ARGUMENTOS:
%	JD	- Fecha Juliana (Julian date, número fraccional!)
% 
% DEVOLUCIÓN:
%	YYYY	- Año
%	MM		- Mes
%	DD		- Día
%	hh		- Hora
%	mm		- Minuto
%	ss		- Segundo

a = fix(JD + 0.5);
b = a + 1537;
c = fix((b-122.1)/365.25);
d = fix(365.25*c);
e = fix((b-d)/30.6001);

td		= b - d - fix(30.6001*e) + mod(JD + 0.5, 1.0);	% [days]
DD		= fix(td);
td		= (td - DD)*24.0;		% [hours]
hh		= fix(td);
td		= (td - hh)*60.0;		% [minutes]
mm		= fix(td);
td		= (td - mm)*60.0;		% [seconds]
ss		= td;
MM		= fix(e - 1 - 12*fix(e/14));
YYYY	= fix(c - 4715 - fix((7.0 + MM)/10.0));

% Check for rollover issues
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