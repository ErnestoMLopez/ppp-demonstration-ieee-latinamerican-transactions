function [datosRNX_OBS] = generarMedicionesSinteticasGps(datosVerdad,datosSP3oRNX_NAV,datosCLK,datosATX_SAT,datosATX_RCV,datosEOP,config)
%GENERARMEDICIONESSINTETICAS A partir de una trayectoria verdad genera
%mediciones GPS
%
% ARGUMENTOS:
%	datosVerdad		- Estructura con los datos verdad de la trayectoria. Debe
%					incluir mínimamente un campo tR con los tiempos de recepción
%					y un campo solPosXYZ con la posición en el marco ECEF. En 
%					caso de haber más datos pueden modelarse más efectos.
%	datosSP3oRNX_NAV- Estructura con datos precisos de órbita o RNIEX de
%					navegación para el cálculo de la órbita de los satélites.
%	datosCLK		- Estructura con datos precisos de reloj de satélite.
%	datosATX_SAT	- Estructura con datos ANTEX, necesaria en caso de utilizar
%					órbitas precisas.
%	datosATX_RCV	- Estructura con datos ANTEX, necesaria en caso de modelar
%					el APC + PCV de receptor.
% 	datosEOP		- Matriz con los datos leídos de un archivo de EOPs.
%	config			- Estructura con parámetros de configuración. 
% 					config = struct(...
% 						'OBSERVABLES', [TipoMedicion.C1C; TipoMedicion.L1C; TipoMedicion.C2C; TipoMedicion.L2C], ...
% 						...
% 						'FLAG_SESGO_RELOJ_SAT',				true, ...
% 						'FLAG_SESGO_RELOJ_RCV',				true, ...
% 						'FLAG_EFECTO_REL',					true, ...
% 						'FLAG_EFECTO_RELGEN',				true, ...
% 						'FLAG_EFECTO_WINDUP',				true, ...
% 						'FLAG_APC_SAT',						true, ...
% 						'FLAG_PCV_SAT',						true, ...
% 						'FLAG_APC_RCV',						true, ...
% 						'FLAG_PCV_RCV',						true, ...
% 						'FLAG_RETARDO_IONO',				true, ...
% 						'FLAG_RETARDO_TROPO',				true, ...
% 						'FLAG_RETARDO_HARDWARE_CODIGO_SAT',	true, ...
% 						'FLAG_RETARDO_HARDWARE_FASE_SAT',	true, ...
% 						'FLAG_RETARDO_HARDWARE_CODIGO_RCV',	true, ...
% 						'FLAG_RETARDO_HARDWARE_FASE_RCV',	true, ...
%						'FLAG_SALTOS_DE_CICLO',				true, ...
%						'FLAG_MUESTRAS_ANOMALAS',			true, ...
% 						...
% 						'IONO_VTEC',				120, ...
%						'IONO_MEAN_HEIGHT_IPP',		350000, ...
% 						...
%						'MASCARA_ELEVACION_ACQ',	15, ...
%						'MASCARA_ELEVACION_TRK',	5, ...
% 						...
% 						'SIGMA_PR',					0.5, ...
% 						'SIGMA_CP',					0.002 ...
% 					);
% 
% DEVOLUCIÓN:
%	datosRNX_OBS	- Estructura de salida con los observables generados.
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 13/01/2020

global LUZ RE;

KK = length(datosVerdad.tR);
CC = length(config.OBSERVABLES);

T = mode(fix(diff(datosVerdad.tR)));
ELEV_MIN = min([config.MASCARA_ELEVACION_ACQ config.MASCARA_ELEVACION_TRK]);

frecuencias = [];
bandas = [];

for cc = 1:CC
	codigo = char(config.OBSERVABLES(cc));
	gpsObs.(codigo) = struct('Valor',	NaN(KK,32), ...
							 'LLI',		zeros(KK,32), ...
							 'SSI',		NaN(KK,32), ...
							 'Modelos', struct( 'Rango',				NaN(KK,32), ...
												'SesgoRelojReceptor',	NaN(KK,32), ...
												'SesgoRelojSatelite',	NaN(KK,32), ...
												'RetardoTroposferico',	NaN(KK,32), ...
												'RetardoIonosferico',	NaN(KK,32), ...
												'APCReceptor',			NaN(KK,32), ...
												'PCVReceptor',			NaN(KK,32), ...
												'APCSatelite',			NaN(KK,32), ...
												'PCVSatelite',			NaN(KK,32), ...
												'RetardoHardwareReceptor',NaN(KK,32), ...
												'RetardoHardwareSatelite',NaN(KK,32), ...
												'EfectoWindUp',			NaN(KK,32), ...
												'AmbiguedadEntera',		NaN(KK,32), ...
												'Multicamino',			NaN(KK,32), ...
												'Ruido',				NaN(KK,32) ...
												) ...
							);
	
	banda = tipoMedicion2bandaFrecuencia(config.OBSERVABLES(cc));
	frecuencias = [frecuencias obtenerFrecuencia(SistemaGNSS.GPS,config.OBSERVABLES(cc),[])];
	if ~ismember(banda,bandas)
		bandas = [bandas banda];
	end
end

FF = length(bandas);

gpsObs.Observables = config.OBSERVABLES;
gpsObs.Visibles = cell(KK,1);


% Memoria para cada componente de las mediciones
elev				= NaN(KK,32);
rango				= zeros(KK,32);		% Inicializo en 0. Los NaN en elevacion
sesgoRelojSatelite	= zeros(KK,32);		% son usados luego para llenar el resto
sesgoRelojReceptor	= zeros(KK,32);
efectoRelativista	= zeros(KK,32);
efectoShapiro		= zeros(KK,32);
efectoWindUp		= zeros(KK,32);
offsetAPCSatelite	= zeros(KK,32,FF);	% Los offset y variaciones dependen de
offsetPCVSatelite	= zeros(KK,32,FF);	% la frecuencia también
offsetAPCReceptor	= zeros(KK,32,FF);
offsetPCVReceptor	= zeros(KK,32,FF);
slantTEC			= zeros(KK,32);
retardoIonosferico  = zeros(KK,32);
retardoTroposferico = zeros(KK,32);
retardoHardwareSatelite	= zeros(KK,32);
retardoHardwareReceptor	= zeros(KK,32);
multicamino			= zeros(KK,32);
ambiguedadEntera	= zeros(KK,32);



% Modelado de las mediciones
for kk = 1:KK
	
	% Tiempo GPS de la época y posición de receptor
	tR = datosVerdad.tR(kk);
	r = datosVerdad.solPosXYZ(kk,:)';
	O_B2F = squeeze(datosVerdad.solOri(:,:,kk));
	
	for jj = 1:32
	
		PRN = jj;
		tV = 70e-3;
		deltatT = 1;
		tT = tR - tV;
		
		while abs(deltatT) > 1e-6		
			[rj,vj,healthy] = estadoSateliteGps(tT,PRN,datosSP3oRNX_NAV);
			
			rj = correccionSagnac(rj,tV);
			vj = correccionSagnac(vj,tV);
			tV = norm(r - rj)/LUZ;

			deltatT = tT - (tR - tV);
			tT = tR - tV;
		end

		if any(isnan(rj))
			continue;
		end
		
		aer = ecefdif2aer(rj,r);
		
		elev(kk,jj) = aer(2);
		rango(kk,jj) = aer(3);	
		
		% Si la elevación es menor que la mínima no tiene sentido seguir. Esto
		% ahorra cómputo y también logra separar los arcos de fase para la 
		% correcta inicialización del efecto wind-up
		if elev(kk,jj) < ELEV_MIN
			continue;
		end
		
		
		if config.FLAG_APC_SAT && strcmp(datosSP3oRNX_NAV.Producto,'SP3')
			for ff = 1:FF
				tipoMed = bandaFrecuencia2tipoMedicionBase(bandas(ff));
				offsetAPCSatelite(kk,jj,ff) = correccionCentroFaseAntenaSateliteGps(tT,r,rj,PRN,tipoMed,datosATX_SAT);
			end
		end
		
		
		if config.FLAG_PCV_SAT && strcmp(datosSP3oRNX_NAV.Producto,'SP3')
			for ff = 1:FF
				tipoMed = bandaFrecuencia2tipoMedicionBase(bandas(ff));
				offsetPCVSatelite(kk,jj,ff) = correccionVariacionCentroFaseAntenaSateliteGps(tT,r,rj,PRN,tipoMed,datosATX_SAT);
			end
		end
		
		
		if config.FLAG_APC_RCV
			for ff = 1:FF
				tipoMed = bandaFrecuencia2tipoMedicionBase(bandas(ff));
				offsetAPCReceptor(kk,jj,ff) = correccionCentroFaseAntenaReceptorGps(r,rj,O_B2F,datosVerdad.Antena,datosVerdad.Domo,tipoMed,datosATX_RCV);
			end
		end
		

		if config.FLAG_SESGO_RELOJ_RCV
			sesgoRelojReceptor(kk,jj) = datosVerdad.solClk(kk,1);
		end
		
			
		if config.FLAG_SESGO_RELOJ_SAT
			if ~isempty(datosCLK)
				corrRelojSatelite = correccionRelojSateliteGps(tT,PRN,datosCLK);
			else
				corrRelojSatelite = correccionRelojSateliteGps(tT,PRN,datosSP3oRNX_NAV);
			end
			if isnan(corrRelojSatelite)				
				continue;
			end
			sesgoRelojSatelite(kk,jj) = corrRelojSatelite;
		end
		
		
		if config.FLAG_EFECTO_REL
			efectoRelativista(kk,jj) = correccionRelativistaSateliteGps(rj,vj);
		end
		
		
		if config.FLAG_EFECTO_RELGEN
			efectoShapiro(kk,jj) = correccionRelativistaGeneral(r,rj);
		end
		
		
		if config.FLAG_RETARDO_IONO
			senz = sind(90 - elev(kk,jj));
			mapeo = 1/(sqrt(1 - (RE*senz)/(RE+config.IONO_MEAN_HEIGHT_IPP)));
			slantTEC(kk,jj) = config.IONO_VTEC*mapeo;
		end
		
		
		if config.FLAG_RETARDO_TROPO
			retardoTroposferico(kk,jj) = correccionTroposfera(tR,r,rj,0);
		end
		
		
		if config.FLAG_EFECTO_WINDUP
			if kk > 1 && ~isnan(efectoWindUp(kk-1,jj))
				efectoWindUp(kk,jj) = correccionWindUp(tR,r,rj,O_B2F,efectoWindUp(kk-1,jj));
			else
				efectoWindUp(kk,jj) = correccionWindUp(tR,r,rj,O_B2F,0);
			end
		end
	end
end


% Una vez modelados todos los términos determinísticos busco cuando se adquieren
% y siguen los satélites de acuerdo a los límites configurados

% Primero elimino todas las elevaciones menores a la máscara mínima
elev(elev < ELEV_MIN) = NaN;

% Ahora elimino los cominezos (o finales) del tracking según la configuración
if config.MASCARA_ELEVACION_ACQ > config.MASCARA_ELEVACION_TRK
	for jj = 1:32
		indx = find(elev(:,jj) < config.MASCARA_ELEVACION_ACQ);
		
		for ii = 1:length(indx)
			if indx(ii) == 1 || isnan(elev(indx(ii)-1,jj))
				elev(indx(ii),jj) = NaN;
			end
		end
	end
else
	for jj = 1:32
		indx = find(elev(:,jj) < config.MASCARA_ELEVACION_TRK);
		
		for ii = length(indx):-1:1
			if indx(ii) == length(indx) || isnan(elev(indx(ii)+1,jj))
				elev(indx(ii),jj) = NaN;
			end
		end
	end	
end


% Genero las listas de satélites visibles
for kk = 1:KK
	prns = find(~isnan(elev(kk,:)))';
	gpsObs.Visibles{kk} = prns;
end


% Elimino las entradas de mediciones que no deberían existir
indx = isnan(elev);

rango(indx)						= NaN;
sesgoRelojSatelite(indx)		= NaN;
sesgoRelojReceptor(indx)		= NaN;
efectoRelativista(indx)			= NaN;
efectoShapiro(indx)				= NaN;
efectoWindUp(indx)				= NaN;
offsetAPCSatelite(indx)			= NaN;
offsetPCVSatelite(indx)			= NaN;
offsetAPCReceptor(indx)			= NaN;
offsetPCVReceptor(indx)			= NaN;
slantTEC(indx)					= NaN;
retardoIonosferico(indx)		= NaN;
retardoTroposferico(indx)		= NaN;
retardoHardwareSatelite(indx)	= NaN;
retardoHardwareReceptor(indx)	= NaN;
multicamino(indx)				= NaN;
ambiguedadEntera(indx)			= NaN;


% Armo cada una de las mediciones, generando los términos faltantes
% (dependientes de frecuencia, tipo de medición y elevación)
for cc = 1:CC
	
	tipo_medicion = config.OBSERVABLES(cc);
	clase_medicion = tipoMedicion2claseMedicion(tipo_medicion);
	codigo = char(tipo_medicion);
	
	frecuencia = obtenerFrecuencia(SistemaGNSS.GPS,tipo_medicion,[]);
	lambda = obtenerLongitudDeOnda(SistemaGNSS.GPS,tipo_medicion,[]);
	banda = tipoMedicion2bandaFrecuencia(tipo_medicion);
	indx_banda = find(bandas == banda);
	
	% Separo los offset que corresponden a la frecuencia del observable actual
	APCReceptor = offsetAPCReceptor(:,:,indx_banda);
	PCVReceptor = offsetPCVReceptor(:,:,indx_banda);
	APCSatelite = offsetAPCSatelite(:,:,indx_banda);
	PCVSatelite = offsetPCVSatelite(:,:,indx_banda);

	retardoIonosferico = 40.3 * slantTEC * 1e16 ./ frecuencia^2;
	
	% factorruido = (sind(elev)).^-1;			% Modelo clásico
	factorruido = 0.9 + 0.1*(sind(elev)).^-2;	% Modelo que ajusta mejor a los satélites GRACE
	
	if clase_medicion == ClaseMedicion.PSEUDORANGO
		
		ruido = config.SIGMA_PR*factorruido.*randn(KK,32);
		
		% TODO: implementar retardos de hardware, multicamino
		
		gpsObs.(codigo).Valor = ...
			rango + efectoShapiro + ...
			LUZ*(sesgoRelojReceptor - sesgoRelojSatelite - efectoRelativista) + ...
			retardoTroposferico + retardoIonosferico + ...
			APCReceptor + PCVReceptor + APCSatelite + PCVSatelite + ...
			retardoHardwareReceptor - retardoHardwareSatelite + ...
			multicamino + ruido;
		
	elseif clase_medicion == ClaseMedicion.FASE_PORTADORA
		
		ruido = config.SIGMA_CP*factorruido.*randn(KK,32);
		
		for jj = 1:32
			indx = find(~isnan(ambiguedadEntera(:,jj)));			
			if isempty(indx)
				continue;
			end
			
			finarco = [find(diff(indx) ~= 1); length(indx)];
			iniarco = indx(1);
			AA = length(finarco);
			
			for aa = 1:AA
				ambiguedadEntera(iniarco:indx(finarco(aa)),jj) = randi([-200 200]);
				
				if aa < AA
					iniarco = indx(finarco(aa) + 1);	% Si hay más arcos sigo
				end
			end
		end
		
		if config.FLAG_SALTOS_DE_CICLO
			aux = elev;
			aux(aux > (config.MASCARA_ELEVACION_ACQ + 5)) = config.MASCARA_ELEVACION_ACQ + 5;
			aux = 1 - aux./(config.MASCARA_ELEVACION_ACQ + 5);
			indx_saltos = rand(size(aux)) < aux;
			
			% Los primeros 5 minutos los dejo libre de saltos
			INI = fix(5*60/T);
			indx_saltos(1:INI,:) = false;
			
			% Para no generar saltos constantes de época en época limito a un
			% minuto como mínimo entre saltos
			INT = fix(60/T);
			for jj = 1:32
				for kk = INI:KK
					if indx_saltos(kk,jj) && any(indx_saltos(kk-INT:kk-1,jj))
						indx_saltos(kk,jj) = false;
					end
				end
			end
			
			saltos = randi([-5,5],KK,32);
			saltos(~indx_saltos) = NaN;
			
			% Agrego los saltos a las ambigüedades
			ambiguedadEntera = ambiguedadEntera + cumsum(saltos,'omitnan');
		end
		
		gpsObs.(codigo).Valor = ...
			rango + efectoShapiro + ...
			LUZ*(sesgoRelojReceptor - sesgoRelojSatelite - efectoRelativista) + ...
			retardoTroposferico - retardoIonosferico + ...
			APCReceptor + PCVReceptor + APCSatelite + PCVSatelite + ...
			retardoHardwareReceptor - retardoHardwareSatelite + ...
			lambda*(efectoWindUp + ambiguedadEntera) + ...
			multicamino + ruido;
	else
		error('Clase de medicion no implementada aun');
	end
	
	% Para facilitar el análisis posterior guardo todos los modelos usados
	gpsObs.(codigo).Modelos.Rango = rango;
	gpsObs.(codigo).Modelos.SesgoRelojReceptor = sesgoRelojReceptor;
	gpsObs.(codigo).Modelos.SesgoRelojSatelite = sesgoRelojSatelite;
	gpsObs.(codigo).Modelos.RetardoTroposferico = retardoTroposferico;
	if clase_medicion == ClaseMedicion.PSEUDORANGO
		gpsObs.(codigo).Modelos.RetardoIonosferico = retardoIonosferico;
	elseif clase_medicion == ClaseMedicion.FASE_PORTADORA
		gpsObs.(codigo).Modelos.RetardoIonosferico = -retardoIonosferico;
	end
	gpsObs.(codigo).Modelos.APCReceptor = APCReceptor;
	gpsObs.(codigo).Modelos.PCVReceptor = PCVReceptor;
	gpsObs.(codigo).Modelos.APCSatelite = APCSatelite;
	gpsObs.(codigo).Modelos.PCVSatelite = PCVSatelite;
	gpsObs.(codigo).Modelos.RetardoHardwareReceptor = retardoHardwareReceptor;
	gpsObs.(codigo).Modelos.RetardoHardwareSatelite = retardoHardwareSatelite;
	gpsObs.(codigo).Modelos.EfectoWindUp = efectoWindUp;
	gpsObs.(codigo).Modelos.AmbiguedadEntera = ambiguedadEntera;
	gpsObs.(codigo).Modelos.SaltosDeCiclo = indx_saltos;
	gpsObs.(codigo).Modelos.Multicamino = multicamino;
	gpsObs.(codigo).Modelos.Ruido = ruido;	
	
end


% Genero la estructura RINEX de salida
if config.FLAG_SESGO_RELOJ_RCV
	datosRNX_OBS.tR = datosVerdad.tR + datosVerdad.solClk(:,1);
else
	datosRNX_OBS.tR = datosVerdad.tR;
end

datosRNX_OBS.GNSS = SistemaGNSS.GPS;
datosRNX_OBS.gpsObs = gpsObs;
datosRNX_OBS.Eventos = zeros(KK,1);
datosRNX_OBS.Estacion = datosVerdad.Estacion;
datosRNX_OBS.Antena = datosVerdad.Antena;
datosRNX_OBS.Domo = datosVerdad.Domo;

end
	