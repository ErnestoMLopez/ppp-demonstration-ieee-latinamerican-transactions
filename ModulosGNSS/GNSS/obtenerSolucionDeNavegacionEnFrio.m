function navSol = obtenerSolucionDeNavegacionEnFrio(kk,datosRNX_OBS,datosSP3oRNX_NAV,datosCLK_SAT,datosConfig)
%OBTENERSOLUCIONDENAVEGACIONENFRIO Calcula una solución de navegación en frío
% Esta función permite obtener en forma simple un estimado grueso de posición y
% sesgo de reloj de receptor para inicialización de otro procesamiento.
% 
% ARGUMENTOS:
%	kk				- Índice de la época en la que se va a calcular
%	datosRNX_OBS	- Estructura de datos devuelta de la lectura de un archivo 
%					RINEX de observables.
% 	datosSP3oRNX_NAV- Estructura de datos para calcular órbitas GNSS. Puede ser	
%					RNX_NAV o SP3, ya sean productos finales, ultra-rapidos o de
%					tiempo real.
% 	datosCLK_SAT	- Estructura de datos devuelta de la lectura de un archivo 
%					CLK o CLK_30S de relojes de satélites GPS.
% 	datosConfig		- Estrucutura con parámetros de configuración establecidos 
%					por el usuario.
% 
% DEVOLUCIÓN:
%	navSol			- Estructura con la solución de navegación PVT
% 
% AUTOR: Ernesto Mauro López
% FECHA: 21/01/2021


global LUZ

datosSatelites = buscarSatelites(kk,datosRNX_OBS,datosConfig);
datosSatelites = modelarEstadoSatelites(kk,datosSatelites,datosRNX_OBS,datosSP3oRNX_NAV,datosCLK_SAT,datosConfig);

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
elseif any(mediciones == TipoMedicion.C1P)
	codigo_med = char(TipoMedicion.C1P);
elseif any(mediciones == TipoMedicion.C2P)
	codigo_med = char(TipoMedicion.C2P);
else
	error('No hay mediciones de pseudorango aptas');
end
	
	
mm = 0;

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
		
		mm = mm + 1;
		
		pseudorango			= datosSatelites(jj).Mediciones(nn).Valor;
		corrRelojSatelite	= datosSatelites(jj).Mediciones(nn).CorrRelojSatelite;
		corrRelativista		= datosSatelites(jj).Mediciones(nn).CorrRelativista;
		
		% Armo el vector de pseudorangos corregidos y la matriz con vectores
		% posición de satélite
		pr(mm) = pseudorango + LUZ*(corrRelojSatelite + corrRelativista);
		rj(mm,:) = datosSatelites(jj).Pos';
		
	end
	
end

% Si no hay al menos 4 mediciones no puedo calcular solución
if mm <= 3
	navSol = NaN(4,1);
	return;
end

% Elimino filas por satélites o mediciones no usadas
pr = pr(1:mm);
rj = rj(1:mm,:);

% Obtengo la solución en frío por Bancroft
navSol = resolverPosicionBancroft(rj,pr);

end
	