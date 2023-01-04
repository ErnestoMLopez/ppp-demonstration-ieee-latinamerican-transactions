function [clkCorr] = correccionRelojSateliteGps(t,PRN,datosProd)
%CORRECIONRELOJSATELITEGPS Obtiene la correcci�n de reloj de un sat�lite GPS
% Obtiene la correcci�n de reloj de sat�lite en base a datos precisos o a los 
% par�metros de correcci�n de reloj de las efem�rides obtenidas de archivos 
% RINEX. 
% En caso de utilizarse datos precisos, si el tiempo coincide con la tasa de los
% datos (sesgos a 30s) se utiliza el valor en forma directa. En caso contrario 
% se realiza una interpolaci�n lineal
% 
% ARGUMENTOS:
%	t			- Tiempo GPS en el cual se desea la correcci�n [s]
%	PRN			- Sat�lite GPS buscado
%	datosProd	- Estructura con los datos obtenidos de un archivo de 
%				relojes precisos .clk o en su defecto de los relojes 
%				precisos a tasa de 15 min de los archivos .sp3, o bien las 
%				efem�rides transmitidas	y levantadas de un archivo RINEX
% 
% DEVOLUCI�N:
%	clkCorr		- Correcci�n de sesgo de reloj de sat�lite en el tiempo dado [s]


%---------- Tengo productos CLK o CLK_30S --------------------------------------
if strcmp(datosProd.Producto,'CLK')

	clkCorr = calcularCorreccionRelojSateliteGps_CLK(t,PRN,datosProd);
		
	
%---------- Tengo productos SP3 ------------------------------------------------
elseif strcmp(datosProd.Producto,'SP3')
	
	clkCorr = calcularCorreccionRelojSateliteGps_SP3(t,PRN,datosProd);
	
	
%---------- Tengo productos RINEX_NAV (efem�rides broadcast) -------------------
elseif strcmp(datosProd.Producto,'RINEX_NAV')
	
	clkCorr = calcularCorreccionRelojSateliteGps_RINEX_NAV(t,PRN,datosProd);

	
%---------- Error en el producto pasado como argumento -------------------------
else
	fprintf('No se hallaron relojes precisos o efem�rides\n');
	clkCorr = NaN;
	return;					% Si no se encuentra nada retorna NaNs
	
end

end
	




