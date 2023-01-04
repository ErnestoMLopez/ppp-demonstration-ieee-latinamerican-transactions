function navSol = PPP_obtenerSolucionEnFrio(kk,datosObs,datosSP3oNavRNX,datosCLK,configPPP)
%PPP_OBTENERSOLUCIONENFRIO Calcula una soluci�n de navegaci�n en fr�o
% Esta funci�n permite obtener en forma simple un estimado grueso de posici�n y
% sesgo de reloj de receptor para inicializaci�n de otro procesamiento.

global LUZ

datosSatelites = buscarSatelites(kk,datosObs,configPPP);
datosSatelites = modelarEstadoSatelites(kk,datosSatelites,datosObs,datosSP3oNavRNX,datosCLK,configPPP);

JJ = length(datosSatelites);
NN = length(datosSatelites(1).Mediciones);

mediciones = [datosSatelites(1).Mediciones.Tipo]';

% Se buscan mediciones de pseudorango, en orden de preferencia PIF, PCIF, C1C
if any(mediciones == TipoMedicion.PIF)
	codigo_med = char(TipoMedicion.PIF);
elseif any(mediciones == TipoMedicion.PCIF)
	codigo_med = char(TipoMedicion.PCIF);
elseif any(mediciones == TipoMedicion.C1C)
	codigo_med = char(TipoMedicion.C1C);
elseif any(mediciones == TipoMedicion.C2C)
	codigo_med = char(TipoMedicion.C2C);
else
	error('No hay mediciones de pseudorango aptas');
end
	
	
mm = 1;

pr = zeros(JJ,1);
rj = zeros(JJ,3);

for jj = 1:JJ
	
	if ~datosSatelites(jj).Usable
		continue;
	end
	
	for nn = 1:NN
		
		if ~datosSatelites(jj).Mediciones(nn).Usable || datosSatelites(jj).Mediciones(nn).Tipo ~= TipoMedicion.(codigo_med)
			continue;
		end
		
		pseudorango			= datosSatelites(jj).Mediciones(nn).Valor;
		corrRelojSatelite	= datosSatelites(jj).Mediciones(nn).CorrRelojSatelite;
		corrRelativista		= datosSatelites(jj).Mediciones(nn).CorrRelativista;
		
		% Armo el vector de pseudorangos corregidos y la matriz con vectores
		% posici�n de sat�lite
		pr(mm) = pseudorango + LUZ*(corrRelojSatelite + corrRelativista);
		rj(mm,:) = datosSatelites(jj).Pos';
		
		mm = mm + 1;
		
	end
	
end

% Elimino filas por sat�lites o mediciones no usadas
pr = pr(1:mm-1);
rj = rj(1:mm-1,:);

% Obtengo la soluci�n en fr�o por Bancroft
navSol = resolverPosicionBancroft(rj,pr);

end
	