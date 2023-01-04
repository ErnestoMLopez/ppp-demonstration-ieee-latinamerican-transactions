function antexAnt = generarEstructuraAntenaANTEX()
%GENERARESTRUCTURAANTENAANTEX Definici�n de la estructura con todos los campos
%necesarios para leer una entrada de un archivo ANTEX correspondiente a una
%antena de receptor.

antexAnt = struct( ...
...% Tipo de antena
	'Antena',		'', ...
...% Tipo de domo
	'Domo',			'', ...
...% Offsets de centro de fase de antena para cada frecuencia
...% 1er indice: Frecuencia, 2do indice: GNSS, 3to indice: Coordenada
	'APC',			zeros(0,0,3), ...
...% Par�metros de PCV azimutal
...% 1er indice: Frecuencia, 2do indice: GNSS,
...% 3er indice: Azimut, 4to indice: �ngulo zenit/nadir
	'DAZI',			0, ...
	'AZI1',			0, ...
	'AZI2',			0, ...
	'NAZI',			0, ...
	'PCVAZI',		zeros(0,0,1,1), ...
...% Par�metros de PCV no-azimutal
...% 1er indice: Frecuencia, 3er indice: GNSS, 4to indice: �ngulo zenit/nadir
	'DZEN',			0, ...
	'ZEN1',			0, ...
	'ZEN2',			0, ...
	'NZEN',			0, ...
	'PCVZEN',		zeros(0,0,1) ...
	);

end