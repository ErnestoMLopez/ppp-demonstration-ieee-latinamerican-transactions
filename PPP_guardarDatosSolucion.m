function datosPPP = PPP_guardarDatosSolucion(kk,datosPPP,xk_post,Pk_post,xk_prior,datosSatelites,datosObsRNX,configPPP)
%PPP_GUARDARDATOSSOLUCION Guardado de datos de la solución
% Una vez ya obtenida la solución para la época guardo todos los datos de los
% satélites, los modelos de las mediciones, ambigüedades estimadas y DOPs. Aún
% no se implementa el cálculo de los residuos postfit
% 
% ARGUMENTOS:
%	kk						- Índice de la época a guardar
%	datosPPP				- Estructura de datos de salida
%	xk_post ((5+NAMB)x1)	- Vector estado a-posteriori de la solución
%	Pk_post ((5+NAMB)x(5+NAMB))	- Matriz de covarianza a-posteriori de la solución
%	xk_prior ((5+NAMB)x1)	- Vector estado a-priori de la solución
%	datosSatelites (JJx1)	- Arreglo de estructuras para los datos de los
%							satélites presentes en la época actual.
%	datosSatelites_post (JJx1)	- Arreglo de estructuras para los datos de los
%							satélites presentes en la época actual pero modelado
%							con la estimación a-posteriori.
%	datosObsRNX				- Estructura de datos devuelta de la lectura de un 
%							archivo RINEX de observables.
%	configPPP				- Estrucutura con parámetros de configuración 
%							establecidos por el usuario.
% 
% DEVOLUCIÓN:
%	datosPPP				- Estructura de datos de salida completada en kk 


% Velocidad de la luz [m/s]
LUZ		= 2.99792458E8;


% Posición estimada ECEF [m]
rk = xk_post(1:3);
r0 = datosObsRNX.PosicionAprox;

% Sesgo de reloj de receptor [s]
dtrk = xk_post(4)/LUZ;

% Corrección ZTD wet
DZTDwk = xk_post(5);


% Cantidad de satélites detectados
JJ = length(datosSatelites);

% Primero hago una pasada por los datos de todos los satélites para sacar
% cantidades de mediciones y de ambigüedades que va a haber
NMED = 0;
NAMB = 0;
NSAT = 0;
for jj = 1:JJ
	if datosSatelites(jj).Usable 
		NSAT = NSAT + 1;
		NN = length(datosSatelites(jj).Mediciones);
		for nn = 1:NN
			flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
			flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
			if flag_med_usable && flag_es_medicion
				NMED = NMED + 1;
				if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
					NAMB = NAMB + 1;
				end
			end
		end
	end
end

% Tiempo de recepción
datosPPP.tR(kk) = datosObsRNX.tR(kk);

% Validez de la solución
if NMED >= 5
	datosPPP.tValid(kk) = true;
end

% Solución de posición
datosPPP.solXYZ(kk,:) = rk';
datosPPP.solLLA(kk,:) = (ecef2llaGeod(rk))';

% Solución del sesgo de reloj de receptor
datosPPP.solClk(kk,:) = dtrk;

% Solución corrección ZTD wet
datosPPP.solDZTDw(kk) = DZTDwk;

% Cantidad de satélites utilizados en la solución
datosPPP.solSVs(kk) = NSAT;

% Error de la solución respecto posición a-priori
datosPPP.errXYZ(kk,:) = (rk - r0)';
datosPPP.errENU(kk,:) = (ecefdif2enu(rk,r0))';

% Desviación estándar de los estimadores
R = ecef2enuMatriz(r0);
PXYZk = Pk_post(1:3,1:3);
PENUk = R*PXYZk*R.';
datosPPP.stdXYZ(kk,:) = (sqrt(diag(PXYZk)))';
datosPPP.stdENU(kk,:) = (sqrt(diag(PENUk)))';
datosPPP.stdClk(kk,:) = sqrt(Pk_post(4,4))/LUZ;
datosPPP.stdDZTDw(kk,:) = sqrt(Pk_post(5,5));




% Para el guardado de los modelos, de residuos prefit y DOPs debo volver a
% recorrer todos los satélites y mediciones

Gk = zeros(NSAT,4);			% Matriz de diseño para calcular DOPs

nsat = 0;
nmed = 0;
namb = 0;

for jj = 1:JJ
	
	PRN = datosSatelites(jj).PRN;
	
	% Guardo los satélites visibles
	datosPPP.gpsSat.Disponibles(kk,PRN) = true;
	
	% Si el satélite no se usó paso al siguiente
	if ~datosSatelites(jj).Usable
		continue;
	end
	
	nsat = nsat + 1;
	
	% Si el satélite es usado guardo sus datos
	datosPPP.gpsSat.Usados(kk,PRN)	= true;
	datosPPP.gpsSat.tV(kk,PRN)		= datosSatelites(jj).tV;
	datosPPP.gpsSat.Pos(kk,:,PRN)	= datosSatelites(jj).Pos';
	datosPPP.gpsSat.Vel(kk,:,PRN)	= datosSatelites(jj).Vel';
	datosPPP.gpsSat.LdV(kk,:,PRN)	= datosSatelites(jj).LdV';
	datosPPP.gpsSat.Azim(kk,PRN)	= datosSatelites(jj).Azim;
	datosPPP.gpsSat.Elev(kk,PRN)	= datosSatelites(jj).Elev;
	datosPPP.gpsSat.Rango(kk,PRN)	= datosSatelites(jj).Rango;
	
	% Voy armando la matriz de diseño
	Gk(nsat,1:3) = -datosSatelites(jj).LdV';
	Gk(nsat,4) = 1;
	
	NN = length(datosSatelites(jj).Mediciones);
	
	for nn = 1:NN
		
		codigo_field = char(datosSatelites(jj).Mediciones(nn).Tipo);
		
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		
		% Si la medición no se usó para el posicionamiento paso a la siguiente
		if ~flag_med_usable || ~flag_es_medicion
			continue;
		end
		
		nmed = nmed + 1;
		
		% Si se usa la medición levanto flag
		datosPPP.gpsObs.(codigo_field).Validez(kk,PRN) = true;
		
		if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
			namb = namb + 1;
		end
		
		% Busco la medición propiamente dicha
		zk = datosSatelites(jj).Mediciones(nn).Valor;
		
		% Obtengo los valores estimados de la medición y calculo de residuos 
		% prefit y posfit (estos útlimos son calculados en base al ajuste lineal
		% del EKF, NO a una reevaluación del modelo no lineal completo de las
		% mediciones)
		zk_est_prior = datosSatelites(jj).Mediciones(nn).ValorEstimado;
		zk_est_post  = datosSatelites(jj).Mediciones(nn).ValorEstimadoPost;
		
		datosPPP.gpsObs.(codigo_field).Prefit(kk,PRN) = zk - zk_est_prior;
		datosPPP.gpsObs.(codigo_field).Posfit(kk,PRN) = zk - zk_est_post;
		
		
		% Guardo todos los terminos del modelo (usado para la solución,
		% o sea el modelo prefit)
		datosPPP.gpsSat.Modelo.CorrRelojSatelite(kk,PRN)					= datosSatelites(jj).Mediciones(nn).CorrRelojSatelite;
		datosPPP.gpsSat.Modelo.CorrRelativista(kk,PRN)						= datosSatelites(jj).Mediciones(nn).CorrRelativista;
		datosPPP.gpsSat.Modelo.CorrPuntoReferenciaAntena(kk,PRN)			= datosSatelites(jj).Mediciones(nn).CorrPuntoReferenciaAntena;
		datosPPP.gpsSat.Modelo.CorrCentroFaseAntenaReceptor(kk,PRN)			= datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaReceptor;
		datosPPP.gpsSat.Modelo.CorrCentroFaseAntenaSatelite(kk,PRN)			= datosSatelites(jj).Mediciones(nn).CorrCentroFaseAntenaSatelite;
		datosPPP.gpsSat.Modelo.CorrVariacionCentroFaseAntenaReceptor(kk,PRN)= datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaReceptor;
		datosPPP.gpsSat.Modelo.CorrVariacionCentroFaseAntenaSatelite(kk,PRN)= datosSatelites(jj).Mediciones(nn).CorrVariacionCentroFaseAntenaSatelite;
		datosPPP.gpsSat.Modelo.CorrWindUp(kk,PRN)							= datosSatelites(jj).Mediciones(nn).CorrWindUp;
		datosPPP.gpsSat.Modelo.CorrTroposfera(kk,PRN)						= datosSatelites(jj).Mediciones(nn).CorrTroposfera;
		datosPPP.gpsSat.Modelo.CorrIonosferaOrdenSup(kk,PRN)				= datosSatelites(jj).Mediciones(nn).CorrIonosferaOrdenSup;
		datosPPP.gpsSat.Modelo.CorrRelativistaGeneral(kk,PRN)				= datosSatelites(jj).Mediciones(nn).CorrRelativistaGeneral;
		datosPPP.gpsSat.Modelo.CorrMareas(kk,PRN)							= datosSatelites(jj).Mediciones(nn).CorrMareas;
		datosPPP.gpsSat.Amb(kk,PRN)											= datosSatelites(jj).Mediciones(nn).Ambig;
		
	end
	
end

% Calculo DOPs
R = ecef2enuMatriz(xk_prior(1:3));
if NSAT >= 4
	matrizDOP = inv(Gk'*Gk);
	matrizDOP(1:3,1:3) = R*matrizDOP(1:3,1:3)*R.';
	DOPs = diag(matrizDOP);
else
	DOPs = NaN(4,1);
end

% Guardo los DOPs
datosPPP.solDOP.GDOP(kk) = sqrt(DOPs(1)+DOPs(2)+DOPs(3)+DOPs(4));
datosPPP.solDOP.PDOP(kk) = sqrt(DOPs(1)+DOPs(2)+DOPs(3));
datosPPP.solDOP.HDOP(kk) = sqrt(DOPs(1)+DOPs(2));
datosPPP.solDOP.VDOP(kk) = sqrt(DOPs(3));
datosPPP.solDOP.TDOP(kk) = sqrt(DOPs(4))/LUZ;

end