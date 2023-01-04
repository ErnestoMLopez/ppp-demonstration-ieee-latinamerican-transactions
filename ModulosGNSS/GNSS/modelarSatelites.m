function datosSatelites = modelarSatelites(kk,datosSatelites,datosSatelitesPrevios,datosObsRNX,datosSP3oNavRNX,datosCLK,datosSatATX,datosRecATX,datosEOP,r,cdtr,DZTDw,Orient_B2F,config)
%MODELARSATELITES Realiza el n�cleo del procesamiento GNSS para cada sat�lite
% A partir de una lista de sat�lites previamente obtenida y de los datos
% le�dos de archivos RINEX, SP3, CLK, ANTEX, etc. modela cada sat�lite
% realizando el n�cleo del procesamiento para cada sat�lite y guardando todos
% los datos en las estructuras pasadas como argumento.
% 
% ARGUMENTOS:
%	kk			- Indice de la �poca dada (con respecto a los datos de observables)
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				sat�lites presentes en la �poca actual.
%	datosSatelitesPrevios (JJprevx1) -  Arreglo de estructuras para los datos de
%				los	sat�lites presentes en la �poca previa (para c�lculo de
%				correcci�n wind-up y carga de las ambig�edades.
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosSP3oNavRNX - Estructura de datos devuelta de la lectura o bien de un 
%				archivo RINEX de navegaci�n o de archivos SP3 de �rbitas 
%				precisas correspondientes a 3 d�as concatenados.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de sat�lites GPS
%	datosSatATX - Arreglo de estructuras con los datos de antenas de sat�lites, 
%				le�dos de un archivo ANTEX.
%	datosRecATX - Arreglo de estructuras con los datos de antenas de receptor, 
%				le�dos de un archivo ANTEX.
% 	datosEOP	- Matriz con los datos le�dos de un archivo de EOPs.
%	r (3x1)		- Vector posici�n ECEF del receptor estimada [m]
%	cdtr		- Estimaci�n del sesgo de reloj del receptor por la velocidad de
%				la luz [m]
%	DZTDw		- Estimaci�n previa de la correcci�n del retardo troposf�rico
%				h�medo zenital.
%	Orient_B2F (3x3) - Matriz de orientaci�n del receptor. Corresponde a la 
%				matriz de transformaci�n de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	config		- Estrucutura con par�metros de configuraci�n establecidos por
%				el usuario.

global LUZ


% Cantidad de sat�lites presentes
JJ = length(datosSatelites);

% Tiempo de recepci�n
tR = datosObsRNX.tR(kk);


% FIXME: Ac� podr�a implementarse algo mejor, que permita utilizar el estimado 
% a-priori del RINEX para un filtro de Kalman linealizado en lugar de 
% extendido por ejemplo. Claro que esto implicar�a tener cuidado luego al 
% incorporar los incrementos de la soluci�n

% Posici�n a-priori del usuario
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

	% Cantidad de mediciones presentes para este sat�lite
	NN = length(datosSatelites(jj).Mediciones);


%-- Obtengo una medici�n de pseudorango ----------------------------------------
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
	

%-- Inicializo el lazo del c�lculo del tiempo de transmisi�n -------------------
	corrRelojSatelite = 0;
	corrRelativista = 0;
	deltatT = 1;
	
	while abs(deltatT) > 1E-9 && healthy

%------ Calculo el tiempo de transmisi�n ---------------------------------------
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		
		
%------ Obtengo el sesgo de reloj de sat�lite en tT ----------------------------
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
		
		
%------ Calculo el estado del sat�lite -----------------------------------------
		[rj,vj,healthy] = estadoSateliteGps(tT,PRN,datosSP3oNavRNX);
		
		if ~healthy
			continue;
		end

%------ Calculo la correcci�n relativista --------------------------------------
		if config.FLAG_CORR_RELATIVISTA
			corrRelativista = correccionRelativistaSateliteGps(rj,vj);
		end
		
		tT1 = tT;
		dt = Rj/LUZ + corrRelojSatelite + corrRelativista;
		tT = tR - dt;
		deltatT = tT  - tT1;
		
	end
	
	
%-- Si el sat�lite no se descart� por falta de reloj o unhealthy guardo datos --
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
	

%-- Detecci�n de eclipses ------------------------------------------------------
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


%-- Correcci�n troposf�rica ----------------------------------------------------
	if config.FLAG_CORR_TROPOSFERA
		[corrTroposfera,mapeoZTDw] = correccionTroposfera(tR,r0,rj,DZTDw);
	else
		corrTroposfera = 0; mapeoZTDw = 0;
	end
	
	
%-- Correcci�n mareas s�lidas y polares ----------------------------------------
	if config.FLAG_CORR_MAREAS
		jd = gpsTime2utcJd(tR);
		EOP = obtenerEOP(jd,datosEOP);
		corrMareas = correccionMareas(tR,r0,rj,EOP);
	else
		corrMareas = 0;
	end


%-- Correcci�n relativista general ---------------------------------------------
	if config.FLAG_CORR_RELATIVISTA_GEN
		corrRelativistaGeneral = correccionRelativistaGeneral(r0,rj);
	else
		corrRelativistaGeneral = 0;
	end	
	
	
%-- Correcci�n por el punto de referencia de la antena de receptor -------------
	if config.FLAG_CORR_ARP
		corrARP = correccionPuntoReferenciaAntena(r0,rj,datosObsRNX.OffsetARP);
	else
		corrARP = 0;
	end	
	

%-- Incremento la edad del sat�lite (�pocas en tracking y usado) --------------
	% Verifico si el sat�lite estaba presente en la �poca previa
	jjprev = find(	([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN) & ...
					([datosSatelitesPrevios.GNSS] == datosSatelites(jj).GNSS) & ...
					([datosSatelitesPrevios.Usable] == datosSatelites(jj).Usable));

	if ~isempty(jjprev)
		datosSatelites(jj).Edad = datosSatelitesPrevios(jjprev).Edad + 1;
	end


%-- Para cada medici�n completo los modelos y busco su valor -------------------
	for nn = 1:NN
		
		codigo_field = char(datosSatelites(jj).Mediciones(nn).Tipo);
		gnss_field = sistemaGNSS2stringEstructura(datosSatelites(jj).GNSS);
		
		% Medici�n propiamente dicha
		datosSatelites(jj).Mediciones(nn).Valor = datosObsRNX.(gnss_field).(codigo_field).Valor(kk,PRN);
		datosSatelites(jj).Mediciones(nn).LLI	= datosObsRNX.(gnss_field).(codigo_field).LLI(kk,PRN);
		datosSatelites(jj).Mediciones(nn).SSI	= datosObsRNX.(gnss_field).(codigo_field).SSI(kk,PRN);
		
		% Verifico que sea v�lida
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
		
		
		% Correcciones APC+PVC de sat�lite
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
		
		% Si se trata de una medici�n de fase hay que modelar ambig�edad y
		% efecto wind-up viendo si se ven�a siguiendo al sat�lite
		corrWindUp = 0;
		if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
		
			% Si el sat�lite estaba presente y se us� su medici�n de fase
			if ~isempty(jjprev) && (datosSatelitesPrevios(jjprev).Mediciones(nn).Usable)
				datosSatelites(jj).Mediciones(nn).Ambig = datosSatelitesPrevios(jjprev).Mediciones(nn).Ambig;
			end
			
			if config.FLAG_CORR_WIND_UP
				if ~isempty(jjprev) && (datosSatelitesPrevios(jjprev).Mediciones(nn).Usable)
					% Calculo la correcci�n wind-up acumulada
					corrWindUp = correccionWindUp(tR,r0,rj,Orient_B2F,datosSatelitesPrevios(jjprev).Mediciones(nn).CorrWindUp);
				else
					corrWindUp = correccionWindUp(tR,r0,rj,Orient_B2F,0);
				end
			end

		end
		
		
		% Guardo todos los modelos de medici�n
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



%-- Si llegu� hasta ac� el sat�lite se usa -------------------------------------
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
%DETECTARECLIPSE Detecci�n de eclipse para una �poca y posici�n dadas
%
% ARGUMENTO:
%	t		- Tiempo GPS de la �poca
%	rj		- Posici�n ECEF para la que se eval�a si est� en eclipse [m]
% 
% DEVOLUCI�N:
%	hay_eclipse - Flag que indica si se encuentra en eclipse o no

global RE

jd = gpsTime2utcJd(t);
rS = posicionSolEcef(jd);			% Posicion del Sol en ECEF
rr = norm(rj);						% Largo vector posici�n de sat�lite
rsrs = norm(rS);					% Largo vector posici�n Sol
cond1 = (rj.'*rS)/(rr*rsrs);		% cos phi
cond2 = rr*sqrt(1-cond1^2);

if (cond1 < 0) && (cond2 < RE)		% Detecci�n de eclipse usando sombra cilindrica
	hay_eclipse = true;
else
	hay_eclipse = false;
end

end
%-------------------------------------------------------------------------------
