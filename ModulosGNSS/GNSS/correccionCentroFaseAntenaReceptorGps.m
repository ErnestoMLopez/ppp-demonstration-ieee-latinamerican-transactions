function apcCorr = correccionCentroFaseAntenaReceptorGps(r,rj,O_B2F,antena,domo,tipoMed,datosATX)
%CORRECCIONCENTROFASERECEPTORSATELITE Corrección por el offset del centro de 
%fase de antena de receptor
% Dado un tiemo GPS, la posición de un satélite, la posición de receptor y los
% datos obtenidos de un archivo ANTEX calcula la corrección por el offset del
% centro de fase de la antena del receptor como su proyección sobre la línea 
% visión del satélite.
% 
% ARGUMENTOS:
%	r (3x1)		- Posición ECEF a-priori del receptor
%	rj (3x1)	- Posición ECEF del satélite
%	O_B2F (3x3) - Matriz de orientación del receptor. Corresponde a la 
%				matriz de transformación de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	antena		- Nombre de la antena de receptor. String de hasta 15 char
%	domo		- Nombre del domo de receptor. String de hasta 4 char
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para determinar 
%				la frecuencia en la que se desea el APC.
%	datosATX	- Estructura de datos provista por la función leerArchivoANTEX
% 
% DEVOLUCIÓN:		
%	apcCorr		- Corrección por el offset del centro de fase de antena de
%				receptor para el modelo de mediciones


% Obtengo el vector línea de visión unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drAPC = calcularVectorCentroFaseAntenaReceptorGps(O_B2F,antena,domo,tipoMed,datosATX);

% Una vez obtenido el APC lo proyecto sobre el vector línea de visión unitario
apcCorr = -dot(LdV,drAPC);

end