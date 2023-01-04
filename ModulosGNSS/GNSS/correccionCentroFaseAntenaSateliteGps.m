function apcCorr = correccionCentroFaseAntenaSateliteGps(t,r,rj,PRN,tipoMed,datosAPC)
%CORRECCIONCENTROFASEANTENASATELITEGPS Correcci�n por el offset del centro de fase
%de antena de sat�lite GPS
% Dado un tiemo GPS, la posici�n de un sat�lite, la posici�n de receptor y los
% datos obtenidos de un archivo ANTEX calcula la correcci�n por el offset del
% centro de fase de la antena del sat�lite respecto al centro de masa como su
% proyecci�n sobre la l�nea visi�n del sat�lite.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n.
%	r (3x1)		- Posici�n ECEF a-priori del receptor
%	rj (3x1)	- Posici�n ECEF del sat�lite
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	tipoMed		- Tipo de medici�n a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la funci�n leerArchivoANTEX
% 
% DEVOLUCI�N:		
%	apcCorr		- Correcci�n por el offset del centro de fase de antena de
%				sat�lite para el modelo de mediciones


% Obtengo el vector l�nea de visi�n unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drAPC = calcularVectorCentroFaseAntenaSateliteGps(t,rj,PRN,tipoMed,datosAPC);

% Una vez obtenido el offset APC lo proyecto sobre el vector l�nea de visi�n
% unitario
apcCorr = dot(LdV,drAPC);

end