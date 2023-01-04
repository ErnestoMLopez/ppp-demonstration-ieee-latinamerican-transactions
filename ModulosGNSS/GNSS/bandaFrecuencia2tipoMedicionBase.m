function tipoMed = bandaFrecuencia2tipoMedicionBase(frec)
%BANDAFRECUENCIA2TIPOMEDICIONBASE Obtiene el tipo de medición básica
% Deveuñlve el tipo de observable básico (pseudorango) asociado a la frecuencia
% correspondiente a la banda especificada
% 
% ARGUMENTOS:
%	frec			- Índice de la banda de frecuencia correspondiente
% 
% DEVOLUCIÓN:
%	tipoMedicion	- Tipo de observable (clase TipoMedicion)
% 
% 
% FECHA: 04/06/2020
% AUTOR: Ernesto Mauro López


if frec == 1
	tipoMed = TipoMedicion.C1C;
elseif frec == 2
	tipoMed = TipoMedicion.C2C;
elseif frec == 3
	tipoMed = TipoMedicion.C3X;
elseif frec == 5
	tipoMed = TipoMedicion.C5X;
elseif frec == 6
	tipoMed = TipoMedicion.C6C;
elseif frec == 7
	tipoMed = TipoMedicion.C7X;
elseif frec == 8
	tipoMed = TipoMedicion.C8X;
elseif frec == 9
	tipoMed = TipoMedicion.C9X;
else
	error('Banda de frecuencia desconocida');
end

	
end