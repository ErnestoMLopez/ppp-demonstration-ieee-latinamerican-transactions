function datosSatelites = generarEstructuraSatelites(JJ,MED)
%GENERARESTRUCTURASATELITES "Definición" de la estructura de satélites visibles
%   Función que emula el comportamiento en C de la definición de una 
%	estructura para luego ser llamada al crear una variable struct
% 
% ARGUMENTOS:
%	JJ			- Cantidad de satélites a guardar
%	MED	(NNx1)	- Vector con los tipos de observables a utilizar (clase
%				TipoMedicion)
% 
% DEVOLUCIÓN:
%	datosSatelites	- Arreglo de estructuras con los datos de los satélites
%					visibles


% Arreglo de substructuras para cada medición. Puedo especificar que medición 
% es, que clase de medición es y contiene todos los campos para el modelo de 
% mediciones, sean o no dependientes del tipo y frecuencia de la medición
Mediciones = generarEstructuraMediciones(MED);

% Estructura con todos los datos necesarios	de un satélite para el procesamiento
% y para el guardado de datos
Satelite = struct(	'PRN',		NaN, ...
					'GNSS',		SistemaGNSS.UNKNOWN_GNSS, ...
					'Block',	SateliteBlock.UNKNOWN_BLOCK, ...
					'Usable',	false, ...
					'Edad',		1, ...
					'tT',		NaN, ...
					'tV',		NaN, ...
					'tEclipse',	NaN, ...
					'Pos',		NaN(3,1), ...
					'Vel',		NaN(3,1), ...
					'Elev',		NaN, ...
					'Azim',		NaN, ...
					'Rango',	NaN, ...
					'LdV',		NaN(3,1), ...
					'Mediciones', Mediciones ...
				);
			
datosSatelites = repmat(Satelite,JJ,1);

end
