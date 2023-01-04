function datosEfemerides = obtenerEfemeridesGps_RINEX_NAV(t,PRN,datosRINEX_NAV)
%OBTENEREFEMERIDESGPS_RINEX_NAV Obtiene las efemérides a partir de un conjunto RINEX
% A partir de una estrucutra de datos RINEX_NAV selecciona las efemérides 
% correctas para el tiempo y el satélite especificados.
%
% ARGUMENTO:
%	t			- Tiempo GPS
%	PRN			- PRN del satélite del que se desean sus efemérides
%	datosRINEX	- Estructura de datos provista por la función	
%				leerArchivoRINEX_NAV a partir de un archivo RINEX de 
%				navegación.
%
% DEVOLUCION:
%	datosEfemerides	- Estructura de datos con las efemérides correspondientes
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 28/12/2020

% Busco las efemérides con el PRN deseado de GPS
PRNs = [datosRINEX_NAV.gpsEph.PRN]';
indx = (PRNs == PRN);

if ~any(indx)
	fprintf('No se encuentra el satelite buscado: PRN = %d\n', PRN)
	return;					% Si no se encuentra nada retorna NaNs
end	

datosEphPRN = datosRINEX_NAV.gpsEph(indx);

ToEs = [datosEphPRN.toe]';
FitInts = [datosEphPRN.FitInterval]';

EE = length(ToEs);

for ee = 1:EE
	difftoe = t - ToEs(ee);
	difftvalidez = 0.5*3600*FitInts(ee);
	
	% Si el tiempo es posterior al tiempo de transmisión de las efemérides
	% (diffttrans > 0), entonces no debería usarlas pensando en que aún no 
	% fueron recibidas. Sin embargo, pedir esto y además que el tiempo esté 
	% dentro del intervalo de validez de las efemérides puede llegar a ser muy 
	% restrictivo (caso empírico con un archivo BRDC, no de una estación) así 
	% que solo pido lo segundo y que al menos dtoe sea negativo
	if difftoe > 0 || difftoe > difftvalidez || difftoe < -difftvalidez
		ephvalid = false;
	else
		ephvalid = true;
		break;
	end
end

% Si no encontré ninguna efemérides válida salgo
if ~ephvalid
	datosEfemerides = [];
	return;
end

datosEfemerides = datosEphPRN(ee);

end