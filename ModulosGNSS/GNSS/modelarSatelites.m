function datosSatelites = modelarSatelites(kk,datosSatelites,datosSatelitesPrevios,datosObsRNX,datosSP3oNavRNX,datosCLK,datosSatATX,datosRecATX,datosEOP,r,cdtr,DZTDw,Orient_B2F,config)
%MODELARSATELITES Realiza el núcleo del procesamiento GNSS para cada satélite
% A partir de una lista de satélites previamente obtenida y de los datos
% leídos de archivos RINEX, SP3, CLK, ANTEX, etc. modela cada satélite
% realizando el núcleo del procesamiento para cada satélite y guardando todos
% los datos en las estructuras pasadas como argumento.
% 
% ARGUMENTOS:
%	kk			- Indice de la época dada (con respecto a los datos de observables)
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				satélites presentes en la época actual.
%	datosSatelitesPrevios (JJprevx1) -  Arreglo de estructuras para los datos de
%				los	satélites presentes en la época previa (para cálculo de
%				corrección wind-up y carga de las ambigüedades.
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosSP3oNavRNX - Estructura de datos devuelta de la lectura o bien de un 
%				archivo RINEX de navegación o de archivos SP3 de órbitas 
%				precisas correspondientes a 3 días concatenados.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de satélites GPS
%	datosSatATX - Arreglo de estructuras con los datos de antenas de satélites, 
%				leídos de un archivo ANTEX.
%	datosRecATX - Arreglo de estructuras con los datos de antenas de receptor, 
%				leídos de un archivo ANTEX.
% 	datosEOP	- Matriz con los datos leídos de un archivo de EOPs.
%	r (3x1)		- Vector posición ECEF del receptor estimada [m]
%	cdtr		- Estimación del sesgo de reloj del receptor por la velocidad de
%				la luz [m]
%	DZTDw		- Estimación previa de la corrección del retardo troposférico
%				húmedo zenital.
%	Orient_B2F (3x3) - Matriz de orientación del receptor. Corresponde a la 
%				matriz de transformación de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	config		- Estrucutura con parámetros de configuración establecidos por
%				el usuario.

global LUZ


% Cantidad de satélites presentes
JJ = length(datosSatelites);

% Tiempo de recepción
tR = datosObsRNX.tR(kk);


% FIXME: Acá podría implementarse algo mejor, que permita utilizar el estimado 
% a-priori del RINEX para un filtro de Kalman linealizado en lugar de 
% extendido por ejemplo. Claro que esto implicaría tener cuidado luego al 
% incorporar los incrementos de la solución

% Posición a-priori del usuario
r0 = r;


	
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


%-- Obtengo una medición de pseudorango ----------------------------------------
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
	

%-- Inicializo el lazo del cálculo del tiempo de transmisión -------------------
	corrRelojSatelite = 0;
	corrRelativista = 0;
	deltatT = 1;
	
	while abs(deltatT) > 1E-9 && healthy

%------ Calculo el tiempo de transmisión ---------------------------------------
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		
		
%------ Obtengo el sesgo de reloj de satélite en tT ----------------------------
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
		
		
%------ Calculo el estado del satélite -----------------------------------------
		[rj,vj,healthy] = estadoSateliteGps(tT,PRN,datosSP3oNavRNX);
		
		if ~healthy
			continue;
		end

%------ Calculo la corrección relativista --------------------------------------
		if config.FLAG_CORR_RELATIVISTA
			corrRelativista = correccionRelativistaSateliteGps(rj,vj);
		end
		
		tT1 = tT;
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		deltatT = tT  - tT1;
		
	end
	
	
%-- Si el satélite no se descartó por falta de reloj o unhealthy guardo datos --
	if ~healthy
		datosSatelites(jj).Usable = false;
		continue;
	else
		datosSatelites(jj).tT = tT;
	end
	

%-- Calculo el tiempo de viaje -------------------------------------------------
	tV = norm(rj-r0)/LUZ;
	
	datosSatelites(jj).tV = tV;
	
	
%-- Corrijo el efecto Sagnac ---------------------------------------------------
	if config.FLAG_CORR_SAGNAC
		rj = correccionSagnac(rj,tV);
		vj = correccionSagnac(vj,tV);
	end

	LdV = (rj-r0)./norm(rj-r0);
	
	datosSatelites(jj).Pos = rj;
	datosSatelites(jj).Vel = vj;
	datosSatelites(jj).LdV = LdV;
	
	
%-- Convierto al marco AER -----------------------------------------------------
	aer = ecefdif2aer(rj,r0);

	datosSatelites(jj).Azim = aer(1);
	datosSatelites(jj).Elev = aer(2);
	datosSatelites(jj).Rango = aer(3);	
	

%-- Detección de eclipses ------------------------------------------------------
	if config.FLAG_SATELITES_ECLIPSE
		if detectarEclipse(tT,rj)
			datosSatelites(jj).tEclipse = tR;
		else
			jjprev = find([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN);
			if ~isempty(jjprev)
				datosSatelites(jj).tEclipse = datosSatelitesPrevios(jjprev).tEclipse;
			end
		end
	end


%-- Corrección troposférica ----------------------------------------------------
	if config.FLAG_CORR_TROPOSFERA
		[corrTroposfera,mapeoZTDw] = correccionTroposfera(tR,r0,rj,DZTDw);
	else
		corrTroposfera = 0; mapeoZTDw = 0;
	end
	
	
%-- Corrección mareas sólidas y polares ----------------------------------------
	if config.FLAG_CORR_MAREAS
		jd = gpsTime2utcJd(tR);
		EOP = obtenerEOP(jd,datosEOP);
		corrMareas = correccionMareas(tR,r0,rj,EOP);
	else
		corrMareas = 0;
	end


%-- Corrección relativista general ---------------------------------------------
	if config.FLAG_CORR_RELATIVISTA_GEN
		corrRelativistaGeneral = correccionRelativistaGeneral(r0,rj);
	else
		corrRelativistaGeneral = 0;
	end	
	
	
%-- Corrección por el punto de referencia de la antena de receptor -------------
	if config.FLAG_CORR_ARP
		corrARP = correccionPuntoReferenciaAntena(r0,rj,datosObsRNX.OffsetARP);
	else
		corrARP = 0;
	end	
	

%-- Incremento la edad del satélite (épocas en tracking y usado) --------------
	% Verifico si el satélite estaba presente en la época previa
	jjprev = find(	([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN) & ...
					([datosSatelitesPrevios.GNSS] == datosSatelites(jj).GNSS) & ...
					([datosSatelitesPrevios.Usable] == datosSatelites(jj).Usable));

	if ~isempty(jjprev)
		datosSatelites(jj).Edad = datosSatelitesPrevios(jjprev).Edad + 1;
	end


%-- Para cada medición completo los modelos y busco su valor -------------------
	for nn = 1:NN
		
		codigo_field = char(datosSatelites(jj).Mediciones(nn).Tipo);
		gnss_field = sistemaGNSS2stringEstructura(datosSatelites(jj).GNSS);
		
		% Medición propiamente dicha
		datosSatelites(jj).Mediciones(nn).Valor = datosObsRNX.(gnss_field).(codigo_field).Valor(kk,PRN);
		datosSatelites(jj).Mediciones(nn).LLI	= datosObsRNX.(gnss_field).(codigo_field).LLI(kk,PRN);
		datosSatelites(jj).Mediciones(nn).SSI	= datosObsRNX.(gnss_field).(codigo_field).SSI(kk,PRN);
		
		% Verifico que sea válida
		if isnan(datosSatelites(jj).Mediciones(nn).Valor)
			datosSatelites(jj).Mediciones(nn).Usable = false;
			continue;
		end
		
		% Si se no es un observable utilizado para posicionamiento no hace falta
		% rellenar los modelos
		flag_es_medicion = any(config.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		
		if ~flag_es_medicion
			continue;
		end		
		
		
		% Correcciones APC+PVC de satélite
		if config.FLAG_CORR_APC_SATELITE && strcmp(datosSP3oNavRNX.Producto,'SP3')
			corrAPCSat = correccionCentroFaseAntenaSateliteGps(tR,r0,rj,PRN,datosSatelites(jj).Mediciones(nn).Tipo,datosSatATX);
		else
			corrAPCSat = 0;
		end
		
		if config.FLAG_CORR_PCV_SATELITE && strcmp(datosSP3oNavRNX.Producto,'SP3')
			corrPVCSat = correccionVariacionCentroFaseAntenaSateliteGps(tR,r0,rj,PRN,datosSatelites(jj).Mediciones(nn).Tipo,datosSatATX);
		else
			corrPVCSat = 0;
		end
		
		if config.FLAG_CORR_APC_RECEPTOR
			corrAPCRec = correccionCentroFaseAntenaReceptorGps(r0,rj,Orient_B2F,datosObsRNX.Antena,datosObsRNX.Domo,datosSatelites(jj).Mediciones(nn).Tipo,datosRecATX);
		else
			corrAPCRec = 0;
		end
		
		if config.FLAG_CORR_PCV_RECEPTOR
			corrPVCRec = correccionVariacionCentroFaseAntenaReceptorGps(r0,rj,Orient_B2F,datosObsRNX.Antena,datosObsRNX.Domo,datosSatelites(jj).Mediciones(nn).Tipo,datosRecATX);
		else
			corrPVCRec = 0;
		end
		
		% Si se trata de una medición de fase hay que modelar ambigüedad y
		% efecto wind-up viendo si se venía siguiendo al satélite
		corrWindUp = 0;
		if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
		
			% Si el satélite estaba presente y se usó su medición de fase
			if ~isempty(jjprev) && (datosSatelitesPrevios(jjprev).Mediciones(nn).Usable)
				datosSatelites(jj).Mediciones(nn).Ambig = datosSatelitesPrevios(jjprev).Mediciones(nn).Ambig;
			end
			
			if config.FLAG_CORR_WIND_UP
				if ~isempty(jjprev) && (datosSatelitesPrevios(jjprev).Mediciones(nn).Usable)
					% Calculo la corrección wind-up acumulada
					corrWindUp = correccionWindUp(tR,r0,rj,Orient_B2F,datosSatelitesPrevios(jjprev).Mediciones(nn).CorrWindUp);
				else
					corrWindUp = correccionWindUp(tR,r0,rj,Orient_B2F,0);
				end
			end

		end
		
		
		% Guardo todos los modelos de medición
		datosSatelites(jj).Mediciones(nn).CorrRelojSatelite = corrRelojSatelite;
		datosSatelites(jj).Mediciones(nn).CorrRelativista = corrRelativista;
		datosSatelites(jj).Mediciones(nn).CorrTroposfera = corrTroposfera;
		datosSatelites(jj).Mediciones(nn).MapeoZTD = mapeoZTDw;
		datosSatelites(jj).Mediciones(nn).CorrMareas = corrMareas;
		datosSatelites(jj).Mediciones(nn).CorrRelativistaGeneral = corrRelativistaGeneral;
		datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaSatelite = corrAPCSat;
		datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaSatelite = corrPVCSat;
		datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaReceptor = corrAPCRec;
		datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaReceptor = corrPVCRec;
		datosSatelites(jj).Mediciones(nn).CorrPuntoReferenciaAntena = corrARP;
		datosSatelites(jj).Mediciones(nn).CorrWindUp = corrWindUp;		
		
	end



%-- Si llegué hasta acá el satélite se usa -------------------------------------
	datosSatelites(jj).Usable = true;
	
end


%-- Una vez modelado todo se estiman las mediciones (para los prefit) ----------
datosSatelites = estimarMediciones(datosSatelites,cdtr);


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



%-------------------------------------------------------------------------------
function hay_eclipse = detectarEclipse(t,rj)
%DETECTARECLIPSE Detección de eclipse para una época y posición dadas
%
% ARGUMENTO:
%	t		- Tiempo GPS de la época
%	rj		- Posición ECEF para la que se evalúa si está en eclipse [m]
% 
% DEVOLUCIÓN:
%	hay_eclipse - Flag que indica si se encuentra en eclipse o no

global RE

jd = gpsTime2utcJd(t);
rS = posicionSolEcef(jd);			% Posicion del Sol en ECEF
rr = norm(rj);						% Largo vector posición de satélite
rsrs = norm(rS);					% Largo vector posición Sol
cond1 = (rj.'*rS)/(rr*rsrs);		% cos phi
cond2 = rr*sqrt(1-cond1^2);

if (cond1 < 0) && (cond2 < RE)		% Detección de eclipse usando sombra cilindrica
	hay_eclipse = true;
else
	hay_eclipse = false;
end

end
%-------------------------------------------------------------------------------
