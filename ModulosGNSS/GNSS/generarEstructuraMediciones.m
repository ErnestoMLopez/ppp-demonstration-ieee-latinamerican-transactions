function datosMediciones = generarEstructuraMediciones(MED)
%GENERARESTRUCTURAMEDICIONES "Definición" de la subestructura de mediciones
%   Función que emula el comportamiento en C de la definición de una 
%	estructura para luego ser llamada al crear una variable struct
% 
% ARGUMENTOS:
%	MED	(NNx1)	- Vector con los tipos de observables a utilizar (clase
%				TipoMedicion)
% 
% DEVOLUCIÓN:
%	datosMediciones	- Arreglo de estructuras con los datos de los satélites
%					visibles
%
%
% AUTOR: Ernesto Mauro López
% FECHA: 10/06/2020


% Arreglo de substructuras para cada medición. Puedo especificar que medición 
% es, que clase de medición es y contiene todos los campos para el modelo de 
% mediciones, sean o no dependientes del tipo y frecuencia de la medición
datosMediciones = struct( ...
	'Tipo',	num2cell(MED), ...								% Clase TipoMedicion
	'Clase',num2cell(tipoMedicion2claseMedicion(MED)), ...	% Clase ClaseMedicion
	'Valor',								NaN, ...		% Medición
	'ValorEstimado',						NaN, ...		% Estimado de la medición (prefit)
	'ValorEstimadoPost',					NaN, ...		% Estimado de la medición (postfit)
	'ValorEstimadoPostAmbigRes',			NaN, ...		% Estimado de la medición (postfit con resolución de ambigüedades)
	'LLI',									NaN, ...		% Loss of Lock Indicator
	'SSI',									NaN, ...		% Signal Strength Indicator
	'Usable', 								true, ...		% Validez de la medición
	'MapeoZTD',								0, ...	% Función de mapeo del retardo troposférico zenital
	'CorrRelojSatelite',					0, ...	% Corrección sesgo de reloj de satélite
	'CorrRelativista',						0, ...	% Corrección relativista de reloj de satélite
	'CorrWindUp',							0, ...	% Corrección de wind-up para las fases
	'CorrTroposfera',						0, ...	% Corrección troposférica
	'CorrIonosfera',						0, ...	% Corrección ionosférica
	'CorrIonosferaOrdenSup',				0, ...	% Corrección ionosférica de orden superior
	'CorrRelativistaGeneral',				0, ...	% Corrección relativista general
	'CorrMareas',							0, ...	% Corrección por mareas sólidas, oceánicas, polares
	'CorrCentroFaseAntenaReceptor',			0, ...	% Corrección APC de antena del receptor
	'CorrCentroFaseAntenaSatelite',			0, ...	% Corrección APC de antena de satélite
	'CorrVariacionCentroFaseAntenaReceptor',0, ...	% Corrección APC de antena del receptor
	'CorrVariacionCentroFaseAntenaSatelite',0, ...	% Corrección APC de antena de satélite
	'CorrPuntoReferenciaAntena',			0, ...	% Corrección ARP de antena del receptor
	'Ambig',								0, ...	% Estimación flotante de la ambigüedad
	'AmbigRes',								0);		% Estimación fija de la ambigüedad resuelta

end