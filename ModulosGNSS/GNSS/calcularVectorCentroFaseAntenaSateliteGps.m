function drAPC = calcularVectorCentroFaseAntenaSateliteGps(t,rj,PRN,tipoMed,datosAPC)
%CALCULARVECTORCENTROFASEANTENASATELITEGPS Obtiene el vector offset APC en el marco ECEF
% 
% ARGUMENTOS:
%	t			- Tiempo GPS de la época en la que se desea el vector
%	rj (3x1)	- Posición ECEF del satélite
%	PRN			- PRN del satélite del que se desea calcular su posición
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la función 
%				leerArchivoANTEX.
% 
% DEVOLUCIÓN:
%	drAPC (3x1)	- Vector offset del centro de fase de la antena de satélite en
%				el marco de referencia ECEF

% Obtengo la posición del Sol en ECEF en la época
JD = gpsTime2utcJd(t);

rS = posicionSolEcef(JD);

% Armo los versores del marco de referencia del satélite
k = -rj./norm(rj);
e = (rS - rj)./norm(rS - rj);
j = cross(k,e)./norm(cross(k,e));
i = cross(j,k)./norm(cross(j,k));

R = [i,j,k];

% Obtenego el vector offset del APC en el marco de referencia del satélite para
% la época y el tipo de medición dados
drAPC_SF = obtenerCentroFaseAntenaSateliteGps(t,PRN,tipoMed,datosAPC);

% Roto del marco de referencia del satélite al ECEF
drAPC = R*drAPC_SF;

end