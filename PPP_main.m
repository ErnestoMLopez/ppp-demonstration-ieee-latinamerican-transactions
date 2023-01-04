function [rutaarchivoppp] = PPP_main(rutaarchivoobs,configPPP)
%PPP_MAIN Programa central para PPP
% A partir de un archivo de observables que debe estar en un directorio con la
% siguiente estructura:
% 
%		../pppdata/DDMMYYYY/EEEE/eeeeWWWWD.YYo
% 
% obtiene los productos necesarios y realiza el procesamiento PPP, guardando los
% datos de salida en un archivo PPPOutputData.mat, en el mismo directorio
% 
% ARGUMENTOS:
%	rutaarchivoobs	- Ruta completa del archivo de observables (respecto a
%						pppscripts)
% 
% DEVOLUCIÓN:
%	rutaarchivoppp	- Ruta completa del archivo con todos los datos usados y la
%					salida del PPP

[filepath,name,ext] = fileparts(rutaarchivoobs);
archivoppp = 'PPPOutputData.mat';
rutaarchivoppp = [filepath '/' archivoppp];

% La lectura de datos automáticamente detecta si los datos ya se encuentran
% leídos y guardados en un .mat
rutaarchivodatos = PPP_obtenerDatosYProductos(rutaarchivoobs);
load(rutaarchivodatos);

% Procesamiento
datosPPP = PPP_procesarDatos(datosObsRNX,datosNavRNX,datosSP3,datosSatCLK,datosSatATX,datosRecATX,datosEOP,configPPP);

% Guardado de datos
save(rutaarchivoppp,'datosPPP','datosObsRNX','datosNavRNX','datosSP3','datosSatCLK','datosEstCLK','datosSatATX','datosRecATX');


end