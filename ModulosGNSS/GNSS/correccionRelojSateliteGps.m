function [clkCorr] = correccionRelojSateliteGps(t,PRN,datosProd)
%CORRECIONRELOJSATELITEGPS Obtiene la corrección de reloj de un satélite GPS
% Obtiene la corrección de reloj de satélite en base a datos precisos o a los 
% parámetros de corrección de reloj de las efemérides obtenidas de archivos 
% RINEX. 
% En caso de utilizarse datos precisos, si el tiempo coincide con la tasa de los
% datos (sesgos a 30s) se utiliza el valor en forma directa. En caso contrario 
% se realiza una interpolación lineal
% 
% ARGUMENTOS:
%	t			- Tiempo GPS en el cual se desea la corrección [s]
%	PRN			- Satélite GPS buscado
%	datosProd	- Estructura con los datos obtenidos de un archivo de 
%				relojes precisos .clk o en su defecto de los relojes 
%				precisos a tasa de 15 min de los archivos .sp3, o bien las 
%				efemérides transmitidas	y levantadas de un archivo RINEX
% 
% DEVOLUCIÓN:
%	clkCorr		- Corrección de sesgo de reloj de satélite en el tiempo dado [s]


%---------- Tengo productos CLK o CLK_30S --------------------------------------
if strcmp(datosProd.Producto,'CLK')

	clkCorr = calcularCorreccionRelojSateliteGps_CLK(t,PRN,datosProd);
		
	
%---------- Tengo productos SP3 ------------------------------------------------
elseif strcmp(datosProd.Producto,'SP3')
	
	clkCorr = calcularCorreccionRelojSateliteGps_SP3(t,PRN,datosProd);
	
	
%---------- Tengo productos RINEX_NAV (efemérides broadcast) -------------------
elseif strcmp(datosProd.Producto,'RINEX_NAV')
	
	clkCorr = calcularCorreccionRelojSateliteGps_RINEX_NAV(t,PRN,datosProd);

	
%---------- Error en el producto pasado como argumento -------------------------
else
	fprintf('No se hallaron relojes precisos o efemérides\n');
	clkCorr = NaN;
	return;					% Si no se encuentra nada retorna NaNs
	
end

end
	




