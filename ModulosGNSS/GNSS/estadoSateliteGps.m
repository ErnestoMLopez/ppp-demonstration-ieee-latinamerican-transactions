function [rs,vs,healthy] = estadoSateliteGps(t,PRN,datosProd)
%ESTADOSATELITEGPS C�mputo del estado de un sat�lite GPS (marco ECEF)
% Calcula el estado de un sat�lite GPS en un tiempo dado a partir de las
% efem�rides del mensaje de navegaci�n o bien de �rbitas precisas, seg�n que
% estructura se pase como argumento.
% Tener en cuenta que si se pasan como argumento efem�rides, el estado
% corresponde al centro de fase de la antena, mientras que si se pasan datos
% de �rbitas precisas el estado calculado por interpolaci�n corresponde al
% centro de masa del sat�lite.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n [s]
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	datosProd	- Estructura de datos dada ya sea por leerArchivoEfemerides o
%				por leerArchivoSP3
%
% DEVOLUCI�N:
%	rj (3x1) -	Posici�n en el marco ECEF para el tiempo GPS dado [m]
%	vj (3x1) -	Velocidad en el marco ECEF para el tiempo GPS dado [m/s]
%	healthy -	Indicador de validez (1) o no (0) del sat�lite


%---------- Tengo productos SP3 ------------------------------------------------
if strcmp(datosProd.Producto,'SP3')
	[rs,vs,healthy] = calcularEstadoSateliteGps_SP3(t,PRN,datosProd);

	
%---------- Tengo productos RINEX_NAV (efem�rides broadcast) -------------------
elseif strcmp(datosProd.Producto,'RINEX_NAV')
	[rs,vs,healthy] = calcularEstadoSateliteGps_RINEX_NAV(t,PRN,datosProd);
	
	
%---------- Error en el producto pasado como argumento -------------------------
else
	fprintf('No se hallaron �rbitas precisas o efem�rides\n');
	rs = NaN(3,1);
	vs = NaN(3,1);
	healthy = false;
	return;					% Si no se encuentra nada retorna NaNs
	
end

end