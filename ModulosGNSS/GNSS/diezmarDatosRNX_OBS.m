function datosObsRNX = diezmarDatosRNX_OBS(datosObsRNX,D)
%DIEZMARDATOSRNX_OBS Diezmado de los observables leídos de un archivo RINEX
% 
% ARGUMENTOS:
%	datosObsRNX		- Estructura de datos devuelta por leerArchivoRNX_OBS
%	D				- Factor de diezmado (número de muestras a diezmar + 1)
% 
% DEVOLUCIÓN:
%	datosObsRNX		- Estructura con los datos de observables diezmados

if D == 1
	return;
end

datosObsRNX.tR = datosObsRNX.tR(1:D:end);
datosObsRNX.Eventos = datosObsRNX.Eventos(1:D:end);

SS = length(datosObsRNX.GNSS);

for ss = 1:SS
	
	gnss_field = sistemaGNSS2stringEstructura(datosObsRNX.GNSS(ss));
	
	datosObsRNX.(gnss_field).Visibles = datosObsRNX.(gnss_field).Visibles(1:D:end);
	
	NN = length(datosObsRNX.(gnss_field).Observables);
	
	for nn = 1:NN
		
		codigo_field = char(datosObsRNX.gpsObs.Observables(nn));
		
		datosObsRNX.(gnss_field).(codigo_field).Valor = datosObsRNX.(gnss_field).(codigo_field).Valor(1:D:end,:);
		datosObsRNX.(gnss_field).(codigo_field).LLI = datosObsRNX.(gnss_field).(codigo_field).LLI(1:D:end,:);
		datosObsRNX.(gnss_field).(codigo_field).SSI = datosObsRNX.(gnss_field).(codigo_field).SSI(1:D:end,:);
		
	end
	
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