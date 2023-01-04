function frec = tipoMedicion2bandaFrecuencia(tipoMed)
%TIPOMEDICION2BANDAFRECUENCIA Obtiene la banda de frecuencia a partir del tipo
%de medición
% Determina la banda de frecuencia del observable especificado de acuerdo al
% estándar RINEX 3.02, el cual es usado como índice de frecuencia durante el
% procesamiento
% 
% ARGUMENTOS:
%	tipoMedicion	- Tipo de observable (clase TipoMedicion)
% 
% DEVOLUCIÓN:
%	frec			- Índice de la banda de frecuencia correspondiente


if tipoMed > TipoMedicion.FIN_OBS	% Combinaciones de observables GPS L1 y L2
	frec = [1, 2];
elseif tipoMed <= TipoMedicion.S1N
	frec = 1;
elseif tipoMed <= TipoMedicion.S2N
	frec = 2;
elseif tipoMed <= TipoMedicion.S3X
	frec = 3;
elseif tipoMed <= TipoMedicion.S5X
	frec = 5;
elseif tipoMed <= TipoMedicion.S6Z
	frec = 6;
elseif tipoMed <= TipoMedicion.S7X
	frec = 7;
elseif tipoMed <= TipoMedicion.S8X
	frec = 8;
elseif tipoMed <= TipoMedicion.S9X
	frec = 9;	
else
	frec = 0;	
end
	
end