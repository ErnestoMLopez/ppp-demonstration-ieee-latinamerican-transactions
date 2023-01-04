function datosObsRNX = seleccionarObservablesyCombinaciones(datosObsRNX,GNSSs,tipo_med)
%SELECCIONAROBSERVABLESYCOMBINACIONES Seleccionar los observables y/o 
% combinaciones de observables pedidos para el procesamiento. Como primer paso
% se verifica la existencia de estos, y en segundo lugar se procede a eleminar
% todos los observables no requeridos. Esto permite una reducción en la carga de
% procesamiento posterior.
% 
% ARGUMENTOS:
%	datosObsRNX		- Estructura de datos obtenida de la lectura de un archivo 
%					RINEX de observables.
%	GNSSs (SSx1)	- Arreglo de objetos clase SistemaGNSS
%	tipo_med (NNx1)	- Arreglo de objetos clase TipoMedicion
% 
% DEVOLUCIÓN:
%	datosObsRNX		- Estructura de datos obtenida de la lectura de un archivo 
%					RINEX de observables con el agregado de las combinaciones de
%					observables requerida y los observables no pedidos
%					eliminados.

% Primero verifico existencia
datosObsRNX = verificarObservablesyCombinaciones(datosObsRNX,GNSSs,tipo_med);

NSIS = length(GNSSs);

for ss = 1:NSIS
	
	gnss_field = sistemaGNSS2stringEstructura(GNSSs(ss));
	NN = length(datosObsRNX.(gnss_field).Observables);
	
	for nn = 1:NN
		obs = datosObsRNX.(gnss_field).Observables(nn);
		if ~ismember(obs,tipo_med)
			datosObsRNX.(gnss_field) = rmfield(datosObsRNX.(gnss_field),char(obs));
		end		
	end
	
	datosObsRNX.(gnss_field).Observables = tipo_med;
	
end
	
end




%-------------------------------------------------------------------------------
function stringGNSS = sistemaGNSS2stringEstructura(SYS)
	
if SYS == SistemaGNSS.GPS
	stringGNSS = 'gpsObs';
	return;
elseif SYS == SistemaGNSS.GLONASS
	stringGNSS = 'glonassObs';
	return;
elseif SYS == SistemaGNSS.Galileo
	stringGNSS = 'galileoObs';
	return;
elseif SYS == SistemaGNSS.BeiDou
	stringGNSS = 'bdsObs';
	return;
elseif SYS == SistemaGNSS.QZSS
	stringGNSS = 'qzssObs';
	return;
elseif SYS == SistemaGNSS.IRNSS
	stringGNSS = 'irnssObs';
	return;	
elseif SYS == SistemaGNSS.SBAS
	stringGNSS = 'sbasObs';
	return;	
end

end
%-------------------------------------------------------------------------------