function [rutaarchivodatos] = PPP_obtenerDatosYProductos(rutaarchivorinexobs)
%PPP_OBTENERDATOSYPRODUCTOS Obtiene todos los datos necesarios para PPP
% A partir de un archivo RINEX_OBS pasado como argumento se lee la fecha a la 
% que corresponde y busca, descarga y lee los archivos de productos IGS
% necesarios para realizar el procesamiento PPP.
% 
% La estructura de carpetas final en pppdata será de la siguiente forma:
% ../pppdata/DDMMYYYY/EEEE/eeeeDOY0.YYo
%						  /PPPInputData.mat
%						  /PPPOutputData.mat
%					 /igsWWWWD.sp3
%					 / ... Demás productos
% 
% ARGUMENTOS:
%	rutaarchivorinexobs - Ruta completa del archivo de observables (respecto a
%						pppscripts)
% 
% DEVOLUCIÓN:
%	rutaarchivodatos	- Ruta completa del archivo con todos los datos para
%						realizar el PPP del archivo pasado como argumento


% filedir es: ../pppdata/DDMMYYYY/EEEE/
[pathstr,name,ext] = fileparts(rutaarchivorinexobs);
filedir = [pathstr '/'];
archivoEstructuraRNX = [name '.mat'];

% Si el archivo ya había sido leído no vuelvo a leerlo, lo cargo
if ~exist([filedir archivoEstructuraRNX],'file')
	disp('Leyendo datos RINEX_OBS')
	datosObsRNX = leerArchivoRINEX_OBS(rutaarchivorinexobs);
	save([filedir archivoEstructuraRNX],'datosObsRNX');
	disp('Datos RINEX_OBS guardados')
else
	load([filedir archivoEstructuraRNX]);
end

% Antes que nada detecto si estos datos ya están leídos y guardados en un .mat
% con el nombre final
archivodatos = 'PPPInputData.mat';
rutaarchivodatos = [filedir archivodatos];

% Si los datos para PPP ya están leídos salgo
if exist([filedir archivodatos],'file')
	return;
end


% Generación nombres archivos
if isfield(datosObsRNX,'TimeFirstObs')
	tgps_first = datosObsRNX.TimeFirstObs;
	tgps_last = datosObsRNX.tR(end);
else
	tgps_first = datosObsRNX.tR(1);
	tgps_last = datosObsRNX.tR(end);
end

[YYYY,MM,DD] = gpsTime2ymdhms(tgps_first);
YY = mod(YYYY,100);
tgps = ymdhms2gpsTime(YYYY,MM,DD,00,00,00);
doy2 = gpsTime2doy(tgps);
doy1 = doy2 - 1;
doy3 = doy2 + 1;
YY1 = YY;
YY2 = YY;
YY3 = YY;
if doy1 < 1
	doy1 = doy1 + 365;
	YY1 = YY - 1;
end
if doy3 > 365
	doy3 = doy3 - 365;
	YY3 = YY3 + 1;
end
[WWWWgps,TOWgps] = gpsTime2gpsWeekTOW(tgps);
DOWgps = fix(TOWgps/86400);

archivonav1 = ['brdc' num2str(doy1,'%03u') '0.' num2str(YY1,'%02u') 'n'];
archivonav2 = ['brdc' num2str(doy2,'%03u') '0.' num2str(YY2,'%02u') 'n'];
archivonav3 = ['brdc' num2str(doy3,'%03u') '0.' num2str(YY3,'%02u') 'n'];
archivosp3 = ['igs' num2str(WWWWgps,'%04u') num2str(DOWgps) '.sp3'];
archivoclk = ['igs' num2str(WWWWgps,'%04u') num2str(DOWgps) '.clk_30s'];


% Descarga de los archivos de productos

% Navegación:
% Verifico que no exista el archivo.
if isempty(dir([filedir, archivonav1]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivonav1}, filedir);
    rutaarchivonav1 = [filedir,temp{1}];
else
	rutaarchivonav1 = [filedir,archivonav1];
end

if isempty(dir([filedir, archivonav2]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivonav2}, filedir);
    rutaarchivonav2 = [filedir,temp{1}];
else
	rutaarchivonav2 = [filedir,archivonav2];
end

if isempty(dir([filedir, archivonav3]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivonav3}, filedir);
    rutaarchivonav3 = [filedir,temp{1}];
else
	rutaarchivonav3 = [filedir,archivonav3];
end


% Relojes:
% Verifico que no exista el archivo.
if isempty(dir([filedir, archivoclk]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivoclk}, filedir);
    rutaarchivoclk = [filedir,temp{1}];
else
	rutaarchivoclk = [filedir,archivoclk];
end

% Orbitas precisas:
% Verifico que no exista el archivo actual.
if isempty(dir([filedir, archivosp3]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivosp3}, filedir);
    rutaarchivosp3 = [filedir,temp{1}];
else
	rutaarchivosp3 = [filedir,archivosp3];
end



% Lectura de los archivos
datosNavRNX1 = leerArchivoRINEX_NAV(rutaarchivonav1);
datosNavRNX2 = leerArchivoRINEX_NAV(rutaarchivonav2);
datosNavRNX3 = leerArchivoRINEX_NAV(rutaarchivonav3);
disp('Datos RINEX_NAV leídos')

datosSP3 = leerArchivoSP3(rutaarchivosp3);
disp('Datos SP3 leídos')

[datosSatCLK,datosEstCLK] = leerArchivoCLK(rutaarchivoclk);
disp('Datos CLK leídos')

% Concateno archivos de navegación
datosNavRNX = datosNavRNX2;
datosNavRNX.gpsEph = [datosNavRNX1.gpsEph; datosNavRNX2.gpsEph; datosNavRNX3.gpsEph];

% Me fijo que sistema utilizó el IGS para las órbitas precisas
sistema = datosSP3.sys;
if str2double(sistema(4:5)) == 05
	archivoantex = 'igs05.atx';
elseif str2double(sistema(4:5)) == 08
	archivoantex = 'igs08.atx';
elseif str2double(sistema(4:5)) == 14
	archivoantex = 'igs14.atx';
else
	archivoantex = 'igs05.atx';
end

[datosSatATX, datosRecATX] = leerArchivoANTEX(archivoantex);
disp('Datos ANTEX leídos')

% También debo guardar los EOP históricos
load EOP.mat

save(rutaarchivodatos,	'datosObsRNX','datosNavRNX','datosSP3', ...
						'datosSatCLK','datosEstCLK', ...
						'datosSatATX','datosRecATX', ...
						'datosEOP');

disp('Datos PPP guardados')

end

