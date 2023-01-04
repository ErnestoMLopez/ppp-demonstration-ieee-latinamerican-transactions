function claseMed = tipoMedicion2claseMedicion(tipoMed)
%TIPOMEDICION2CLASEMEDICION Determina que clase de medición a partir de su tipo
% A partir del tipo de medición, obtenido en base a su código RINEX 3.0 o la
% combinación que sea, determina si se trata de un pseudorango, fase de
% portadora, doppler, relación portadora a ruido, retardo ionosférico, canal del
% receptor u otro en caso de ser una combinación.
% 
% ARGUMENTOS:
%	tipoMed - Tipo de medición (clase TipoMedicion)
% 
% DEVOLUCIÓN:
%	claseMed - Clase de medición (clase ClaseMedicion)

NN = length(tipoMed);
claseMed = repmat(ClaseMedicion.UNKNOWN_CLASSMED,NN,1);

for nn = 1:NN
	
	codigo = char(tipoMed(nn));
	
	% Si es un observable RINEX determino en forma directa
	if tipoMed(nn) <= TipoMedicion.S6Z
		
		if codigo(1) == 'C'
			claseMed(nn) = ClaseMedicion.PSEUDORANGO;
		elseif codigo(1) == 'L'
			claseMed(nn) = ClaseMedicion.FASE_PORTADORA;
		elseif codigo(1) == 'D'
			claseMed(nn) = ClaseMedicion.DOPPLER;
		elseif codigo(1) == 'S'
			claseMed(nn) = ClaseMedicion.CN0;
		elseif codigo(1) == 'I'
			claseMed(nn) = ClaseMedicion.RETARDO_IONOSFERICO;
		elseif codigo(1) == 'X'
			claseMed(nn) = ClaseMedicion.CANAL_RECEPTOR;
		end
		
		% Si es una combinación me fijo que clase es
	else
		
		if codigo(1) == 'P'
			claseMed(nn) = ClaseMedicion.PSEUDORANGO;
		elseif codigo(1) == 'L'
			claseMed(nn) = ClaseMedicion.FASE_PORTADORA;
		elseif codigo(1) == 'G'
			claseMed(nn) = ClaseMedicion.FASE_PORTADORA;
		else
			claseMed(nn) = ClaseMedicion.COMBINACION;
		end
	end
	
end

end
	
	
	
	
	