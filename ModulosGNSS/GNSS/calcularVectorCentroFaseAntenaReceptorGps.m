function drAPC = calcularVectorCentroFaseAntenaReceptorGps(O_R2F,antena,domo,tipoMed,datosATX)
%CALCULARVECTORCENTROFASEANTENARECEPTORGPS Obtiene el vector offset APC en el marco ECEF
% 
% ARGUMENTOS:
%	O_R2F (3x3) - Matriz de orientación del receptor. Corresponde a la 
%				matriz de transformación de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	antena		- Nombre de la antena de receptor. String de hasta 15 char
%	domo		- Nombre del domo de receptor. String de hasta 4 char
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosATX	- Estructura de datos provista por la función 
%				leerArchivoANTEX.
% 
% DEVOLUCIÓN:
%	drAPC (3x1)	- Vector offset del centro de fase de la antena de receptor en
%				el marco de referencia ECEF


% Obtenego el vector offset del APC en el marco de referencia del satélite para
% la época y el tipo de medición dados
drAPC_ENU = obtenerCentroFaseAntenaReceptorGps(antena,domo,tipoMed,datosATX);

% Roto del marco de referencia del receptor al ECEF
drAPC = O_R2F*drAPC_ENU;

end