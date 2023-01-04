function [D, M] = doy2daymonth(Y,DOY)
%DOY2DAYMONTH Convierte el día del año en el día y mes correspondiente
% 
% ARGUMENTOS:
%	Y		- Año a convertir
%	DOY		- Día del año a convertir
%
% DEVOLUCIÓN:
%	D		- Día del mes
%	M		- Mes del año

if (DOY <= 31)
	M = 1;
	D = DOY;
else
	if (yeardays(Y) == 365)
		if (DOY <= 58)
			M = 2;
			D = DOY - 31;
		elseif ((58 < DOY) && (DOY <= 90))
			M = 3;
			D = DOY - 59;
		elseif ((90 < DOY) && (DOY <= 120))
			M = 4;
			D = DOY - 90;
		elseif ((120 < DOY) && (DOY <= 151))
			M = 5;
			D = DOY - 120;
		elseif ((151 < DOY) && (DOY <= 181))
			M = 6;
			D = DOY - 151;
		elseif ((181 < DOY) && (DOY <= 212))
			M = 7;
			D = DOY - 181;
		elseif ((212 < DOY) && (DOY <= 243))
			M = 8;
			D = DOY - 212;
		elseif ((243 < DOY) && (DOY <= 273))
			M = 9;
			D = DOY - 243;
		elseif ((273 < DOY) && (DOY <= 304))
			M = 10;
			D = DOY - 273;
		elseif ((304 < DOY) && (DOY <= 334))
			M = 11;
			D = DOY - 304;
		else
			M = 12;
			D = DOY - 334;
		end
			
	else	% Si es un año bisiesto
		if (DOY <= 59)
			M = 2;
			D = DOY - 31;
		elseif ((59 < DOY) && (DOY <= 91))
			M = 3;
			D = DOY - 60;
		elseif ((91 < DOY) && (DOY <= 121))
			M = 4;
			D = DOY - 91;
		elseif ((121 < DOY) && (DOY <= 152))
			M = 5;
			D = DOY - 121;
		elseif ((152 < DOY) && (DOY <= 182))
			M = 6;
			D = DOY - 152;
		elseif ((182 < DOY) && (DOY <= 213))
			M = 7;
			D = DOY - 182;
		elseif ((213 < DOY) && (DOY <= 244))
			M = 8;
			D = DOY - 213;
		elseif ((244 < DOY) && (DOY <= 274))
			M = 9;
			D = DOY - 244;
		elseif ((274 < DOY) && (DOY <= 305))
			M = 10;
			D = DOY - 274;
		elseif ((305 < DOY) && (DOY <= 335))
			M = 11;
			D = DOY - 305;
		else
			M = 12;
			D = DOY - 335;
		end
	end
end

end

