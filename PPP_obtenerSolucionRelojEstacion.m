function datosEstCLK = PPP_obtenerSolucionRelojEstacion(Estacion,DD,MM,YYYY)
%PPP_OBTENERSOLUCIONRELOJESTACION Descarga y lee archivo RINEX_CLK
% En caso de estar disponibles esta funci�n descarga el archivo de soluci�n
% de relojes de una estaci�n IGS de la fecha especificada
% 
% ARGUMENTOS:
% 	Estacion 	- Nombre de la estaci�n IGS (en may�sculas)
% 	DD,MM,YYYY 	- D�a, mes y a�o a descargar
% 
% DEVOLUCI�N:
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

% Si el archivo est� descargado lo leo sino devuelvo vac�o
if status == 1
	[~,datosEstCLK] = leerArchivoCLK(rutaarchivoclk);
else
	datosEstCLK = [];
	return;
end

end