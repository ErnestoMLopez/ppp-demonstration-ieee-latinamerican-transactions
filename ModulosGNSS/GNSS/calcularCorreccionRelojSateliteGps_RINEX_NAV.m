function [clkCorr] = calcularCorreccionRelojSateliteGps_RINEX_NAV(t,PRN,datosRINEX_NAV)
%CALCULARCORRECCIONRELOJSATELITEGPS_RINEX_NAV Obtiene la correcci�n de reloj de un sat�lite GPS
% Obtiene la correcci�n de reloj de sat�lite en base a las correcciones de
% reloj de las efem�rides contenidas en el mensaje de navegaci�n, obtenidas a
% traves de un archivo RINEX de navegaci�n.
%
% ARGUMENTO:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n.
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	datosRINEX	- Estructura de datos provista por la funci�n	
%				leerArchivoRINEX_NAV a partir de un archivo RINEX de 
%				navegaci�n.
%
% DEVOLUCION:
%	clkCorr		- Correcci�n de sesgo de reloj de sat�lite en el tiempo dado [s]

clkCorr = NaN;

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
	return;
end

% Reduzco el conjunto de estructuras de efemerides a las del sat�lite 
toc		= datosEphPRN(ee).toc;
af0		= datosEphPRN(ee).af0;
af1		= datosEphPRN(ee).af1;
af2		= datosEphPRN(ee).af2;

% Me quedo con la diferencia de tiempo correcta entre toe y le �poca
dt = t - toc;

% C�lculo de la correcci�n de reloj [s]
clkCorr = (af2*dt + af1)*dt + af0;
	
end