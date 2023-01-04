function datosPPP = PPP_generarEstructuraSalida(KK,datosObs,configPPP)
%PPP_GENERARESTRUCTURASALIDA "Definici�n" de la estructura de salida PPP
%   Funci�n que emula el comportamiento en C de la definici�n de una 
%	estructura para luego ser llamada al crear una variable struct
% 
% ARGUMENTOS:
%	KK			- Cantidad de �pocas de las que se quiere guardar observables
%	datosObs	- Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	configPPP	- Estrucutura con par�metros de configuraci�n establecidos por
%				el usuario.

datosPPP = struct( ...
	'Estacion',	datosObs.Estacion, ...			% Estaci�n
	'tR',		zeros(KK,1), ...	% Tiempos de recepci�n
	'tValid',	false(KK,1),...		% Tiempos con soluci�n v�lida
	'solXYZ',	NaN(KK,3), ...		% Posici�n estimada (ECEF)
	'solLLA',	NaN(KK,3), ...		% Posici�n estimada (latitud, longitud y altura con respecto al elipsoide)
	'solClk',	NaN(KK,1), ...		% Sesgo de reloj de receptor estimado
	'solDZTDw',	NaN(KK,1), ...		% Estimacion de la correcci�n del ZTD wet
	'solSVs',	NaN(KK,1), ...		% Cantidad de sat�lites utilizados en la soluci�n
	'errXYZ',   NaN(KK,3), ...		% Error posici�n estimada (ECEF) con respecto a posici�n a priori (RINEX)
	'errENU',	NaN(KK,3), ...		% Error posici�n estimada (ENU) con respecto a posici�n a priori (RINEX)
	'stdXYZ',	NaN(KK,3), ...		% Desviaci�n est�ndar posici�n (ECEF)
	'stdENU',	NaN(KK,3), ...		% Desviaci�n est�ndar posici�n (ENU)
	'stdClk',	NaN(KK,1), ...		% Desviaci�n est�ndar del sesgo de reloj.
	'stdDZTDw',	NaN(KK,1), ...		% Desviaci�n est�ndar correcci�n del ZTD wet
	'solDOP', 	struct( ...
			 'GDOP', NaN(KK,1),...  % Diluci�n de la precisi�n geom�trica
			 'PDOP', NaN(KK,1),...  % Diluci�n de la precisi�n de posici�n
			 'VDOP', NaN(KK,1),...  % Diluci�n de la precisi�n vertical
			 'HDOP', NaN(KK,1),...  % Diluci�n de la precisi�n horizontal
			 'TDOP', NaN(KK,1)...   % Diluci�n de la precisi�n temporal
			), ...
	'gpsSat',	struct( ...			% Datos de la constelaci�n para cada �poca (en el tiempo de transmisi�n de cada sat�lite!)
			'Disponibles', false(KK,32), ...% Sat�lite presentes en la �poca
			'Usados', false(KK,32), ...		% Sat�lite usados en la soluci�n de la �poca
			'tT',	NaN(KK,32), ...			% Tiempo de transmisi�n (en tiempo GPS)
			'tV',	NaN(KK,32), ...			% Tiempo de viaje a-priori (rango geom�trico)
			'Pos',	NaN(KK,3,32), ...		% Posici�n de sat�lite en tt
			'Vel',	NaN(KK,3,32), ...		% Velocidad de sat�lite en tt
			'Amb',	NaN(KK,32), ...			% Ambig�edades estimadas en el filtro
			'Elev',	NaN(KK,32), ...			% Elevaci�n
			'Azim',	NaN(KK,32), ...			% Azimut
			'Rango',NaN(KK,32), ...			% Rango
			'LdV',	NaN(KK,3,32), ...		% Vector l�nea de visi�n unitario
			'Modelo', struct( ...
					'CorrRelojSatelite',			NaN(KK,32), ...			% Correcci�n sesgo de reloj de sat�lite
					'CorrRelativista',				NaN(KK,32), ...			% Correcci�n relativista de reloj de sat�lite
					'CorrPuntoReferenciaAntena',	NaN(KK,32), ...			% Correcci�n ARP de antena del receptor
					'CorrCentroFaseAntenaReceptor', NaN(KK,32), ...			% Correcci�n APC de antena del receptor
					'CorrCentroFaseAntenaSatelite', NaN(KK,32), ...			% Correcci�n APC de antena de sat�lite
					'CorrVariacionCentroFaseAntenaReceptor', NaN(KK,32), ...% Correcci�n APC de antena del receptor
					'CorrVariacionCentroFaseAntenaSatelite', NaN(KK,32), ...% Correcci�n APC de antena de sat�lite
					'CorrWindUp',					NaN(KK,32), ...			% Correcci�n de wind-up para las fases
					'CorrTroposfera',				NaN(KK,32), ...			% Correcci�n troposf�rica
					'CorrIonosferaOrdenSup',		NaN(KK,32), ...			% Correcci�n ionosf�rica de orden superior
					'CorrRelativistaGeneral',		NaN(KK,32), ...			% Correcci�n relativista general
					'CorrMareas',					NaN(KK,32) ...			% Correcci�n por mareas s�lidas, oce�nicas, polares
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