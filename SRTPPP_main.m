function [rutaarchivosrtppp] = SRTPPP_main(rutaarchivoobs,configSRTPPP)
%SRTPPP_MAIN Programa central para SRT-PPP
% A partir de un archivo de observables que debe estar en un directorio con la
% siguiente estructura:
% 
%		../pppdata/DDMMYYYY/EEEE/eeeeWWWWD.YYo
% 
% obtiene los productos necesarios y realiza el procesamiento SRTPPP, guardando 
% los datos de salida en un archivo SRTPPPOutputData.mat, en el mismo directorio
% 
% ARGUMENTOS:
%	rutaarchivoobs		- Ruta completa del archivo de observables (respecto a
%						pppscripts)
% 
% DEVOLUCIÓN:
%	rutaarchivosrtppp	- Ruta completa del archivo con todos los datos usados y
%						la salida del SRTPPP


[filepath,name,ext] = fileparts(rutaarchivoobs);
archivoppp = 'SRTPPPOutputData.mat';
rutaarchivosrtppp = [filepath '/' archivoppp];

% La lectura de datos automáticamente detecta si los datos ya se encuentran
% leídos y guardados en un .mat
rutaarchivodatos = SRTPPP_obtenerDatosYProductos(rutaarchivoobs);
load(rutaarchivodatos);

% Procesamiento QRTPPP
datosSRTPPP = SRTPPP_procesarDatos(datosObsRNX,datosSP3,datosSatCLK,datosSatATX,datosRecATX,datosERP,configSRTPPP);

% Guardado de datos
save(rutaarchivosrtppp,'datosSRTPPP','datosObsRNX','datosSP3','datosSatATX','datosRecATX');

end

