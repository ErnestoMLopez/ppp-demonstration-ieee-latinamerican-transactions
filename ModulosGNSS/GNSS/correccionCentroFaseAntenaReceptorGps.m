function apcCorr = correccionCentroFaseAntenaReceptorGps(r,rj,O_B2F,antena,domo,tipoMed,datosATX)
%CORRECCIONCENTROFASERECEPTORSATELITE Correcci�n por el offset del centro de 
%fase de antena de receptor
% Dado un tiemo GPS, la posici�n de un sat�lite, la posici�n de receptor y los
% datos obtenidos de un archivo ANTEX calcula la correcci�n por el offset del
% centro de fase de la antena del receptor como su proyecci�n sobre la l�nea 
% visi�n del sat�lite.
% 
% ARGUMENTOS:
%	r (3x1)		- Posici�n ECEF a-priori del receptor
%	rj (3x1)	- Posici�n ECEF del sat�lite
%	O_B2F (3x3) - Matriz de orientaci�n del receptor. Corresponde a la 
%				matriz de transformaci�n de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	antena		- Nombre de la antena de receptor. String de hasta 15 char
%	domo		- Nombre del domo de receptor. String de hasta 4 char
%	tipoMed		- Tipo de medici�n a usar (clase TipoMedicion), para determinar 
%				la frecuencia en la que se desea el APC.
%	datosATX	- Estructura de datos provista por la funci�n leerArchivoANTEX
% 
% DEVOLUCI�N:		
%	apcCorr		- Correcci�n por el offset del centro de fase de antena de
%				receptor para el modelo de mediciones


% Obtengo el vector l�nea de visi�n unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drAPC = calcularVectorCentroFaseAntenaReceptorGps(O_B2F,antena,domo,tipoMed,datosATX);

% Una vez obtenido el APC lo proyecto sobre el vector l�nea de visi�n unitario
apcCorr = -dot(LdV,drAPC);

end