function [rs,vs,healthy] = estadoSateliteGps(t,PRN,datosProd)
%ESTADOSATELITEGPS Cómputo del estado de un satélite GPS (marco ECEF)
% Calcula el estado de un satélite GPS en un tiempo dado a partir de las
% efemérides del mensaje de navegación o bien de órbitas precisas, según que
% estructura se pase como argumento.
% Tener en cuenta que si se pasan como argumento efemérides, el estado
% corresponde al centro de fase de la antena, mientras que si se pasan datos
% de órbitas precisas el estado calculado por interpolación corresponde al
% centro de masa del satélite.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición [s]
%	PRN			- PRN del satélite del que se desea calcular su posición
%	datosProd	- Estructura de datos dada ya sea por leerArchivoEfemerides o
%				por leerArchivoSP3
%
% DEVOLUCIÓN:
%	rj (3x1) -	Posición en el marco ECEF para el tiempo GPS dado [m]
%	vj (3x1) -	Velocidad en el marco ECEF para el tiempo GPS dado [m/s]
%	healthy -	Indicador de validez (1) o no (0) del satélite


%---------- Tengo productos SP3 ------------------------------------------------
if strcmp(datosProd.Producto,'SP3')
	[rs,vs,healthy] = calcularEstadoSateliteGps_SP3(t,PRN,datosProd);

	
%---------- Tengo productos RINEX_NAV (efemérides broadcast) -------------------
elseif strcmp(datosProd.Producto,'RINEX_NAV')
	[rs,vs,healthy] = calcularEstadoSateliteGps_RINEX_NAV(t,PRN,datosProd);
	
	
%---------- Error en el producto pasado como argumento -------------------------
else
	fprintf('No se hallaron órbitas precisas o efemérides\n');
	rs = NaN(3,1);
	vs = NaN(3,1);
	healthy = false;
	return;					% Si no se encuentra nada retorna NaNs
	
end

end