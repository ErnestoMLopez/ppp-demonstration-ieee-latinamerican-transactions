function datosZPD = PPP_obtenerSolucionTroposfericaEstacion(Estacion,DD,MM,YYYY)
%PPP_OBTENERSOLUCIONTROPOSFERICAESTACION Descarga y lee archivo SINEX_TRO
% En caso de estar disponibles esta función descarga el archivo de solución
% troposférica de una estación IGS de la fecha especificada
% 
% ARGUMENTOS:
% 	Estacion 	- Nombre de la estación IGS (en mayúsculas)
% 	DD,MM,YYYY 	- Día, mes y año a descargar
% 
% DEVOLUCIóN:
% 	datosZPD 	- Estructura de datos ZPD devuelta por leerArchivoZPD


% Si los datos no están guardados en un .mat entonces los descargo
YY = mod(YYYY,100);
	
doy = ymd2doy(YYYY,MM,DD);
	
	
archivozpd = [lower(Estacion) num2str(doy,'%03u') '0.' num2str(YY,'%02u') 'zpd'];

filedir = ['../pppdata/' num2str(DD,'%02u') num2str(MM,'%02u') num2str(YYYY,'%04u') '/' Estacion '/'];

% Si la ruta de guardado no existe la creo
if ~exist(filedir,'dir')
	mkdir(filedir);
end

% Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
if isempty(dir([filedir, archivozpd]))
	[status, temp] = descargarArchivosGNSS({archivozpd}, filedir);
	rutaarchivonxtro = [filedir temp{1}];
else
	status = 1;
	rutaarchivonxtro = [filedir archivozpd];
end

if status == 1
	datosZPD = leerArchivoZPD(rutaarchivonxtro);
else
	datosZPD = [];
end

end