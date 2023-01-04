function datosSatelites = modelarEstadoSatelites(kk,datosSatelites,datosObsRNX,datosSP3oNavRNX,datosCLK,config)
%MODELARESTADOSATELITES Obtiene el estado y sesgo de reloj de los satélites
% A partir de una lista de satélites previamente obtenida y de los datos
% leídos de archivos RINEX, SP3 y CLK calcula el estado de cada satélite 
% rellenando la estructura de los mismos. 
% Notar que este proceso consiste basicamente en la primera parte de la función
% modelarSatelites. Esta función está pensada para un arranque completamente en
% frío de cualquier procesamiento, por lo que se aceptan errores groseros.
% 
% ARGUMENTOS:
%	kk			- Indice de la época dada (con respecto a los datos de observables)
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				satélites presentes en la época actual.
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosSP3oNavRNX - Estructura de datos devuelta de la lectura o bien de un 
%				archivo RINEX de navegación o de archivos SP3 de órbitas 
%				precisas.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de satélites GPS
%	config		- Estrucutura con parámetros de configuración establecidos por
%				el usuario.

global LUZ


% Cantidad de satélites presentes
JJ = length(datosSatelites);

% Tiempo de recepción
tR = datosObsRNX.tR(kk);

	
for jj = 1:JJ
	
	% Por ahora lo considero healthy
	healthy = true;
	
	% Por ahora no se soportan otros GNSS
	if datosSatelites(jj).GNSS ~= SistemaGNSS.GPS
		datosSatelites(jj).Usable = false;
		continue;
	end
	
	PRN = datosSatelites(jj).PRN;

	% Cantidad de mediciones presentes para este satélite
	NN = length(datosSatelites(jj).Mediciones);
	
	% Obtengo una medición de pseudorango
	if isfield(datosObsRNX.gpsObs,'PIF')
		Rj = datosObsRNX.gpsObs.PIF.Valor(kk,PRN);
	elseif isfield(datosObsRNX.gpsObs,'PCIF')
		Rj = datosObsRNX.gpsObs.PCIF.Valor(kk,PRN);
	elseif isfield(datosObsRNX.gpsObs,'C1C')
		Rj = datosObsRNX.gpsObs.C1C.Valor(kk,PRN);
	elseif isfield(datosObsRNX.gpsObs,'C1P')
		Rj = datosObsRNX.gpsObs.C1P.Valor(kk,PRN);
	else
		datosSatelites(jj).Usable = false;
		continue;
	end
	if isnan(Rj)
		datosSatelites(jj).Usable = false;
		continue;
	end
	

	% Inicializo el lazo del cálculo del tiempo de transmisión
	corrRelojSatelite = 0;
	corrRelativista = 0;
	deltatT = 1;
	
	while abs(deltatT) > 1E-9 && healthy

		% Calculo el tiempo de transmisión
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		
		
		% Obtengo el sesgo de reloj de satélite en tT 
		if config.FLAG_CORR_RELOJ_SATELITE
			if ~isempty(datosCLK)
				corrRelojSatelite = correccionRelojSateliteGps(tT,PRN,datosCLK);
			else
				corrRelojSatelite = correccionRelojSateliteGps(tT,PRN,datosSP3oNavRNX);
			end
		end
		if isnan(corrRelojSatelite)
			healthy = false;
			continue;
		end
		
		
		% Calculo el estado del satélite en tT
		[rj,vj,healthy] = estadoSateliteGps(tT,PRN,datosSP3oNavRNX);
		
		if ~healthy
			continue;
		end

		% Calculo la corrección relativista
		if config.FLAG_CORR_RELATIVISTA
			corrRelativista = correccionRelativistaSateliteGps(rj,vj);
		end
		
		tT1 = tT;
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		deltatT = tT  - tT1;
		
	end
	
	
	% Si el satélite no se descartó por falta de reloj o unhealthy guardo datos 
	if ~healthy
		datosSatelites(jj).Usable = false;
		continue;
	else
		datosSatelites(jj).tT = tT;
	end
	

	% Guardo el tiempo de viaje basado en pseudorango. Notar que contiene el 
	% sesgo de reloj de receptor!!
	tV = dt;
	
	datosSatelites(jj).tV = tV;
	
	
	% Corrijo el efecto Sagnac 
	if config.FLAG_CORR_SAGNAC
		rj = correccionSagnac(rj,tV);
		vj = correccionSagnac(vj,tV);
	end
	
	datosSatelites(jj).Pos = rj;
	datosSatelites(jj).Vel = vj;
	
	% Para cada medición busco su valor y lo guardo
	for nn = 1:NN
		
		codigo_field = char(datosSatelites(jj).Mediciones(nn).Tipo);
		gnss_field = sistemaGNSS2stringEstructura(datosSatelites(jj).GNSS);
		
		% Guardo la medición propiamente dicha y correcciones
		datosSatelites(jj).Mediciones(nn).Valor = datosObsRNX.(gnss_field).(codigo_field).Valor(kk,PRN);
		datosSatelites(jj).Mediciones(nn).LLI	= datosObsRNX.(gnss_field).(codigo_field).LLI(kk,PRN);
		datosSatelites(jj).Mediciones(nn).SSI	= datosObsRNX.(gnss_field).(codigo_field).SSI(kk,PRN);
		datosSatelites(jj).Mediciones(nn).CorrRelojSatelite = corrRelojSatelite;
		datosSatelites(jj).Mediciones(nn).CorrRelativista = corrRelativista;
		
		% Verifico que sea válida
		if isnan(datosSatelites(jj).Mediciones(nn).Valor)
			datosSatelites(jj).Mediciones(nn).Usable = false;
			continue;
		end
		
	end
		
		
	% Si llegué hasta acá el satélite se usa
	datosSatelites(jj).Usable = true;
	
end

end


%-------------------------------------------------------------------------------
function stringGNSS = sistemaGNSS2stringEstructura(SYS)
	
if SYS == SistemaGNSS.GPS
	stringGNSS = 'gpsObs';
	return;
elseif SYS == SistemaGNSS.GLONASS
	stringGNSS = 'glonassObs';
	return;
elseif SYS == SistemaGNSS.Galileo
	stringGNSS = 'galileoObs';
	return;
elseif SYS == SistemaGNSS.BeiDou
	stringGNSS = 'bdsObs';
	return;
elseif SYS == SistemaGNSS.QZSS
	stringGNSS = 'qzssObs';
	return;
elseif SYS == SistemaGNSS.IRNSS
	stringGNSS = 'irnssObs';
	return;	
elseif SYS == SistemaGNSS.SBAS
	stringGNSS = 'sbasObs';
	return;	
end

end
%-------------------------------------------------------------------------------
