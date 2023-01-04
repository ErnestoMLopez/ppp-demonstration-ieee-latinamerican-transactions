function apcCorr = correccionCentroFaseAntenaSateliteGps(t,r,rj,PRN,tipoMed,datosAPC)
%CORRECCIONCENTROFASEANTENASATELITEGPS Corrección por el offset del centro de fase
%de antena de satélite GPS
% Dado un tiemo GPS, la posición de un satélite, la posición de receptor y los
% datos obtenidos de un archivo ANTEX calcula la corrección por el offset del
% centro de fase de la antena del satélite respecto al centro de masa como su
% proyección sobre la línea visión del satélite.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición.
%	r (3x1)		- Posición ECEF a-priori del receptor
%	rj (3x1)	- Posición ECEF del satélite
%	PRN			- PRN del satélite del que se desea calcular su posición
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la función leerArchivoANTEX
% 
% DEVOLUCIÓN:		
%	apcCorr		- Corrección por el offset del centro de fase de antena de
%				satélite para el modelo de mediciones


% Obtengo el vector línea de visión unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drAPC = calcularVectorCentroFaseAntenaSateliteGps(t,rj,PRN,tipoMed,datosAPC);

% Una vez obtenido el offset APC lo proyecto sobre el vector línea de visión
% unitario
apcCorr = dot(LdV,drAPC);

end