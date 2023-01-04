function datosEfemerides = obtenerEfemeridesGps_RINEX_NAV(t,PRN,datosRINEX_NAV)
%OBTENEREFEMERIDESGPS_RINEX_NAV Obtiene las efem�rides a partir de un conjunto RINEX
% A partir de una estrucutra de datos RINEX_NAV selecciona las efem�rides 
% correctas para el tiempo y el sat�lite especificados.
%
% ARGUMENTO:
%	t			- Tiempo GPS
%	PRN			- PRN del sat�lite del que se desean sus efem�rides
%	datosRINEX	- Estructura de datos provista por la funci�n	
%				leerArchivoRINEX_NAV a partir de un archivo RINEX de 
%				navegaci�n.
%
% DEVOLUCION:
%	datosEfemerides	- Estructura de datos con las efem�rides correspondientes
% 
% 
% AUTOR: Ernesto Mauro L�pez
% FECHA: 28/12/2020

% Busco las efem�rides con el PRN deseado de GPS
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
	
	% Si el tiempo es posterior al tiempo de transmisi�n de las efem�rides
	% (diffttrans > 0), entonces no deber�a usarlas pensando en que a�n no 
	% fueron recibidas. Sin embargo, pedir esto y adem�s que el tiempo est� 
	% dentro del intervalo de validez de las efem�rides puede llegar a ser muy 
	% restrictivo (caso emp�rico con un archivo BRDC, no de una estaci�n) as� 
	% que solo pido lo segundo y que al menos dtoe sea negativo
	if difftoe > 0 || difftoe > difftvalidez || difftoe < -difftvalidez
		ephvalid = false;
	else
		ephvalid = true;
		break;
	end
end

% Si no encontr� ninguna efem�rides v�lida salgo
if ~ephvalid
	datosEfemerides = [];
	return;
end

datosEfemerides = datosEphPRN(ee);

end