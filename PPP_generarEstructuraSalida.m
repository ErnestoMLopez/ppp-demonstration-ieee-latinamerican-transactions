function datosPPP = PPP_generarEstructuraSalida(KK,datosObs,configPPP)
%PPP_GENERARESTRUCTURASALIDA "Definición" de la estructura de salida PPP
%   Función que emula el comportamiento en C de la definición de una 
%	estructura para luego ser llamada al crear una variable struct
% 
% ARGUMENTOS:
%	KK			- Cantidad de épocas de las que se quiere guardar observables
%	datosObs	- Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	configPPP	- Estrucutura con parámetros de configuración establecidos por
%				el usuario.

datosPPP = struct( ...
	'Estacion',	datosObs.Estacion, ...			% Estación
	'tR',		zeros(KK,1), ...	% Tiempos de recepción
	'tValid',	false(KK,1),...		% Tiempos con solución válida
	'solXYZ',	NaN(KK,3), ...		% Posición estimada (ECEF)
	'solLLA',	NaN(KK,3), ...		% Posición estimada (latitud, longitud y altura con respecto al elipsoide)
	'solClk',	NaN(KK,1), ...		% Sesgo de reloj de receptor estimado
	'solDZTDw',	NaN(KK,1), ...		% Estimacion de la corrección del ZTD wet
	'solSVs',	NaN(KK,1), ...		% Cantidad de satélites utilizados en la solución
	'errXYZ',   NaN(KK,3), ...		% Error posición estimada (ECEF) con respecto a posición a priori (RINEX)
	'errENU',	NaN(KK,3), ...		% Error posición estimada (ENU) con respecto a posición a priori (RINEX)
	'stdXYZ',	NaN(KK,3), ...		% Desviación estándar posición (ECEF)
	'stdENU',	NaN(KK,3), ...		% Desviación estándar posición (ENU)
	'stdClk',	NaN(KK,1), ...		% Desviación estándar del sesgo de reloj.
	'stdDZTDw',	NaN(KK,1), ...		% Desviación estándar corrección del ZTD wet
	'solDOP', 	struct( ...
			 'GDOP', NaN(KK,1),...  % Dilución de la precisión geométrica
			 'PDOP', NaN(KK,1),...  % Dilución de la precisión de posición
			 'VDOP', NaN(KK,1),...  % Dilución de la precisión vertical
			 'HDOP', NaN(KK,1),...  % Dilución de la precisión horizontal
			 'TDOP', NaN(KK,1)...   % Dilución de la precisión temporal
			), ...
	'gpsSat',	struct( ...			% Datos de la constelación para cada época (en el tiempo de transmisión de cada satélite!)
			'Disponibles', false(KK,32), ...% Satélite presentes en la época
			'Usados', false(KK,32), ...		% Satélite usados en la solución de la época
			'tT',	NaN(KK,32), ...			% Tiempo de transmisión (en tiempo GPS)
			'tV',	NaN(KK,32), ...			% Tiempo de viaje a-priori (rango geométrico)
			'Pos',	NaN(KK,3,32), ...		% Posición de satélite en tt
			'Vel',	NaN(KK,3,32), ...		% Velocidad de satélite en tt
			'Amb',	NaN(KK,32), ...			% Ambigüedades estimadas en el filtro
			'Elev',	NaN(KK,32), ...			% Elevación
			'Azim',	NaN(KK,32), ...			% Azimut
			'Rango',NaN(KK,32), ...			% Rango
			'LdV',	NaN(KK,3,32), ...		% Vector línea de visión unitario
			'Modelo', struct( ...
					'CorrRelojSatelite',			NaN(KK,32), ...			% Corrección sesgo de reloj de satélite
					'CorrRelativista',				NaN(KK,32), ...			% Corrección relativista de reloj de satélite
					'CorrPuntoReferenciaAntena',	NaN(KK,32), ...			% Corrección ARP de antena del receptor
					'CorrCentroFaseAntenaReceptor', NaN(KK,32), ...			% Corrección APC de antena del receptor
					'CorrCentroFaseAntenaSatelite', NaN(KK,32), ...			% Corrección APC de antena de satélite
					'CorrVariacionCentroFaseAntenaReceptor', NaN(KK,32), ...% Corrección APC de antena del receptor
					'CorrVariacionCentroFaseAntenaSatelite', NaN(KK,32), ...% Corrección APC de antena de satélite
					'CorrWindUp',					NaN(KK,32), ...			% Corrección de wind-up para las fases
					'CorrTroposfera',				NaN(KK,32), ...			% Corrección troposférica
					'CorrIonosferaOrdenSup',		NaN(KK,32), ...			% Corrección ionosférica de orden superior
					'CorrRelativistaGeneral',		NaN(KK,32), ...			% Corrección relativista general
					'CorrMareas',					NaN(KK,32) ...			% Corrección por mareas sólidas, oceánicas, polares
					) ...
			), ...
	'gpsObs', generarEstructuraObservablesGps(KK,configPPP.MEDICIONES) ...
);

end




function sobs = generarEstructuraObservablesGps(KK,MED)

smed = struct( ...
			'Validez',	false(KK,32), ...	% Validez de cada tipo de observable
			'Posfit',	NaN(KK,32), ...
			'Prefit',	NaN(KK,32) ...
);

NOBS = length(MED);
sobs = cell2struct(repmat({smed},NOBS,1),cellstr(string(MED)),1);
sobs.Observables = cellstr(string(MED));

end