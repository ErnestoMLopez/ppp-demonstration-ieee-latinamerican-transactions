function datosEstCLK = PPP_obtenerSolucionRelojEstacion(Estacion,DD,MM,YYYY)
%PPP_OBTENERSOLUCIONRELOJESTACION Descarga y lee archivo RINEX_CLK
% En caso de estar disponibles esta función descarga el archivo de solución
% de relojes de una estación IGS de la fecha especificada
% 
% ARGUMENTOS:
% 	Estacion 	- Nombre de la estación IGS (en mayúsculas)
% 	DD,MM,YYYY 	- Día, mes y año a descargar
% 
% DEVOLUCIÓN:
% 	datosEstCLK - Estructura de datos CLK devuelta por leerArchivoCLK

tgps = ymdhms2gpsTime(YYYY,MM,DD,00,00,00);
[WWWWgps,TOWgps] = gpsTime2gpsWeekTOW(tgps);
DOWgps = fix(TOWgps/86400);

archivoclk = ['igs' num2str(WWWWgps,'%04u') num2str(DOWgps) '.clk_30s'];	

filedir = ['../pppdata/' num2str(DD,'%02u') num2str(MM,'%02u') num2str(YYYY,'%04u') '/' Estacion '/'];

% Si la ruta de guardado no existe la creo
if ~exist(filedir,'dir')
	mkdir(filedir);
end

% Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
if isempty(dir([filedir, archivoclk]))
	[status, temp] = descargarArchivosGNSS({archivoclk}, filedir);
	rutaarchivoclk = [filedir temp{1}];
else
	status = 1;
	rutaarchivoclk = [filedir archivoclk];
end

% Si el archivo está descargado lo leo sino devuelvo vacío
if status == 1
	[~,datosEstCLK] = leerArchivoCLK(rutaarchivoclk);
else
	datosEstCLK = [];
	return;
end

end