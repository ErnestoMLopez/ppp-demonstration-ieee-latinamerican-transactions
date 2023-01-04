function datosSatelites = buscarSatelites(kk,datosObsRNX,config)
%BUSCARSATELITES Para una época dada busca los satélites presentes
% Esta función permite encontrar los satélites presentes de cualquier GNSS
% deseado en una época dada y genera estructuras para el posterior guardado de
% los datos necesarios para el procesamiento.
%
% ARGUMENTOS:
%	kk			- Indice de la época dada (con respecto a los datos de observables)
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	config		- Estrucutura con parámetros de configuración establecidos por
%				el usuario.
% 
% DEVOLUCIÓN:
%	datosSatelites (JJx1) -  Arreglo de estructuras para los datos de los
%				satélites presentes en la época actual. Se inicializa en NaN
%				excepto los campos PRN y GNSS para identificar a los satélites.



SS = length(config.GNSS);

gpsJJ = 0;
glonassJJ = 0;
galileoJJ = 0;
sbasJJ = 0;
bdsJJ = 0;
qzssJJ = 0;
irnssJJ = 0;


for ss = 1:SS
	flag_gps_presente	= any(datosObsRNX.GNSS == SistemaGNSS.GPS);
	flag_glo_presente	= any(datosObsRNX.GNSS == SistemaGNSS.GLONASS);
	flag_gal_presente	= any(datosObsRNX.GNSS == SistemaGNSS.Galileo);
	flag_sbas_presente	= any(datosObsRNX.GNSS == SistemaGNSS.SBAS);
	flag_bds_presente	= any(datosObsRNX.GNSS == SistemaGNSS.BeiDou);
	flag_qzss_presente	= any(datosObsRNX.GNSS == SistemaGNSS.QZSS);
	flag_irnss_presente = any(datosObsRNX.GNSS == SistemaGNSS.IRNSS);
	
	if config.GNSS(ss) == SistemaGNSS.GPS && flag_gps_presente
		gpsPRN = sort(datosObsRNX.gpsObs.Visibles{kk});		% Busco la lista de visibles ORDENADA por PRN
		gpsJJ = length(gpsPRN);
	elseif config.GNSS(ss) == SistemaGNSS.GLONASS && flag_glo_presente
		glonassPRN = sort(datosObsRNX.glonassObs.Visibles{kk});
		glonassJJ = length(glonassPRN);
	elseif config.GNSS(ss) == SistemaGNSS.Galileo && flag_gal_presente
		galileoPRN = sort(datosObsRNX.galileoObs.Visibles{kk});
		galileoJJ = length(galileoPRN);
	elseif config.GNSS(ss) == SistemaGNSS.SBAS && flag_sbas_presente
		sbasPRN = sort(datosObsRNX.sbasObs.Visibles{kk});
		sbasJJ = length(sbasPRN);
	elseif config.GNSS(ss) == SistemaGNSS.BeiDou && flag_bds_presente
		bdsPRN = sort(datosObsRNX.bdsObs.Visibles{kk});
		bdsJJ = length(bdsPRN);
	elseif config.GNSS(ss) == SistemaGNSS.QZSS && flag_qzss_presente
		qzssPRN = sort(datosObsRNX.qzssObs.Visibles{kk});
		qzssJJ = length(qzssPRN);
	elseif config.GNSS(ss) == SistemaGNSS.IRNSS && flag_irnss_presente
		irnssPRN = sort(datosObsRNX.irnssObs.Visibles{kk});
		irnssJJ = length(irnssPRN);
	end
end


% Inicializo un arreglo vacío para ir concatenando luego
datosSatelites = generarEstructuraSatelites(0,config.OBSERVABLES);

% Inicializo el arreglo de estructuras para todos los satélites de la época
if gpsJJ > 0
	datosSatelitesGps = generarEstructuraSatelites(gpsJJ,datosObsRNX.gpsObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesGps];
end
if glonassJJ > 0
	datosSatelitesGlonass = generarEstructuraSatelites(glonassJJ,datosObsRNX.glonassObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesGlonass];
end
if galileoJJ > 0
	datosSatelitesGalileo = generarEstructuraSatelites(galileoJJ,datosObsRNX.galileoObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesGalileo];
end
if sbasJJ > 0
	datosSatelitesSbas = generarEstructuraSatelites(sbasJJ,datosObsRNX.sbasObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesSbas];
end
if bdsJJ > 0
	datosSatelitesBds = generarEstructuraSatelites(bdsJJ,datosObsRNX.bdsObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesBds];
end
if qzssJJ > 0
	datosSatelitesQzss = generarEstructuraSatelites(qzssJJ,datosObsRNX.qzssObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesQzss];
end
if irnssJJ > 0
	datosSatelitesIrnss	= generarEstructuraSatelites(irnssJJ,datosObsRNX.irnssObs.Observables);
	datosSatelites = [datosSatelites; datosSatelitesIrnss];
end


% Cargo los datos básicos de cada satélite para después completar el modelo 
for jj = 1:gpsJJ
	
	datosSatelites(jj).GNSS = SistemaGNSS.GPS;
	datosSatelites(jj).PRN = gpsPRN(jj);
	datosSatelites(jj).Usable = true;
	
end


% Si se agrega soporte para más GNSSs:
for jj = 1:glonassJJ
	
	datosSatelites(gpsJJ + jj).GNSS = SistemaGNSS.GLONASS;
	datosSatelites(gpsJJ + jj).PRN = glonassPRN(jj);
	datosSatelites(gpsJJ + jj).Usable = true;
	
end

for jj = 1:galileoJJ
	
	datosSatelites(gpsJJ + glonassJJ + jj).GNSS = SistemaGNSS.Galileo;
	datosSatelites(gpsJJ + glonassJJ + jj).PRN = galileoPRN(jj);
	datosSatelites(gpsJJ + glonassJJ + jj).Usable = true;
	
end

for jj = 1:sbasJJ
	
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + jj).GNSS = SistemaGNSS.SBAS;
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + jj).PRN = sbasPRN(jj);
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + jj).Usable = true;
	
end
for jj = 1:bdsJJ
	
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + jj).GNSS = SistemaGNSS.BeiDou;
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + jj).PRN = bdsPRN(jj);
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + jj).Usable = true;
	
end
for jj = 1:qzssJJ
	
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + jj).GNSS = SistemaGNSS.QZSS;
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + jj).PRN = qzssPRN(jj);
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + jj).Usable = true;
	
end
for jj = 1:irnssJJ
	
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + irnssJJ + jj).GNSS = SistemaGNSS.IRNSS;
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + irnssJJ + jj).PRN = irnssPRN(jj);
	datosSatelites(gpsJJ + glonassJJ + galileoJJ + sbasJJ + bdsJJ + irnssJJ + jj).Usable = true;
	
end

end




