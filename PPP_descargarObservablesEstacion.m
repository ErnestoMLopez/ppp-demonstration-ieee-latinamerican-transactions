function rutaarchivornxobs = PPP_descargarObservablesEstacion(Estacion,DD,MM,YYYY)
%PPP_DESCARGAROBSERVABLESESTACION Descarga archivo RINEX de observables
% En caso de estar disponibles esta función descarga el archivo de observables 
% diario de una estación IGS de la fecha especificada
% 
% ARGUMENTOS:
% 	Estacion 	- Nombre de la estación IGS (en mayúsculas)
% 	DD,MM,YYYY 	- Día, mes y año a descargar
% 
% DEVOLUCIóN:
% 	rutaarchivornxobs 	- Ruta completa del archivo descargado (relativa a pppscripts)


% Si los datos no están guardados en un .mat entonces los descargo
YY = mod(YYYY,100);
	
tgps = ymdhms2gpsTime(YYYY,MM,DD,00,00,00);
	
doy = gpsTime2doy(tgps);
	
	
archivoobs = [lower(Estacion) num2str(doy,'%03u') '0.' num2str(YY,'%02u') 'o'];

filedir = ['./pppdata/' num2str(DD,'%02u') num2str(MM,'%02u') num2str(YYYY,'%04u') '/' Estacion '/'];

% Si la ruta de guardado no existe la creo
if ~exist(filedir,'dir')
	mkdir(filedir);
end

% Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
if isempty(dir([filedir, archivoobs]))
	[status, temp] = descargarArchivosGNSS({archivoobs}, filedir);
	rutaarchivornxobs = [filedir temp{1}];
else
	rutaarchivornxobs = [filedir archivoobs];
end

end