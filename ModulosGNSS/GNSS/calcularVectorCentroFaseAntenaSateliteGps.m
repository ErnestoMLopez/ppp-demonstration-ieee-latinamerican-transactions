function drAPC = calcularVectorCentroFaseAntenaSateliteGps(t,rj,PRN,tipoMed,datosAPC)
%CALCULARVECTORCENTROFASEANTENASATELITEGPS Obtiene el vector offset APC en el marco ECEF
% 
% ARGUMENTOS:
%	t			- Tiempo GPS de la �poca en la que se desea el vector
%	rj (3x1)	- Posici�n ECEF del sat�lite
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	tipoMed		- Tipo de medici�n a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la funci�n 
%				leerArchivoANTEX.
% 
% DEVOLUCI�N:
%	drAPC (3x1)	- Vector offset del centro de fase de la antena de sat�lite en
%				el marco de referencia ECEF

% Obtengo la posici�n del Sol en ECEF en la �poca
JD = gpsTime2utcJd(t);

rS = posicionSolEcef(JD);

% Armo los versores del marco de referencia del sat�lite
k = -rj./norm(rj);
e = (rS - rj)./norm(rS - rj);
j = cross(k,e)./norm(cross(k,e));
i = cross(j,k)./norm(cross(j,k));

R = [i,j,k];

% Obtenego el vector offset del APC en el marco de referencia del sat�lite para
% la �poca y el tipo de medici�n dados
drAPC_SF = obtenerCentroFaseAntenaSateliteGps(t,PRN,tipoMed,datosAPC);

% Roto del marco de referencia del sat�lite al ECEF
drAPC = R*drAPC_SF;

end