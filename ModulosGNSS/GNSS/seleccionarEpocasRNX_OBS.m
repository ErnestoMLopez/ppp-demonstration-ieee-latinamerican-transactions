function datosObsRNX = seleccionarEpocasRNX_OBS(indx,datosObsRNX)
%SELECCIONAREPOCASRNX_OBS Elimina las épocas de observables no indexados
% 
% ARGUMENTOS:
%	indx (KKx1)		- Vector con los indicesde las épocas a seleccionar
%	datosObsRNX		- Estructura de datos RINEX.
% 
% DEVOLUCION:
%	datosObsRNX		- Estructura de datos RINEX con las épocas seleccionadas
% 
% 
% AUTOR: Ernesto mauro López
% FECHA: 05/05/2019


datosObsRNX.tR = datosObsRNX.tR(indx);
datosObsRNX.Eventos = datosObsRNX.Eventos(indx);

SS = length(datosObsRNX.GNSS);

for ss = 1:SS
	
	gnss_field = sistemaGNSS2stringEstructura(datosObsRNX.GNSS(ss));
	
	datosObsRNX.(gnss_field).Visibles = datosObsRNX.(gnss_field).Visibles(indx);
	
	CC = length(datosObsRNX.(gnss_field).Observables);
	
	for cc = 1:CC

		codigo_field = char(datosObsRNX.(gnss_field).Observables(cc));
		
		datosObsRNX.(gnss_field).(codigo_field).Valor = datosObsRNX.(gnss_field).(codigo_field).Valor(indx,:);
		datosObsRNX.(gnss_field).(codigo_field).SSI = datosObsRNX.(gnss_field).(codigo_field).SSI(indx,:);
		datosObsRNX.(gnss_field).(codigo_field).LLI = datosObsRNX.(gnss_field).(codigo_field).LLI(indx,:);
		
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