function [rutaarchivodatos] = SRTPPP_obtenerDatosYProductos(rutaarchivorinexobs)
%SRTPPP_OBTENERDATOSYPRODUCTOS Obtiene todos los datos necesarios para SRTPPP
% A partir de un archivo RINEX_OBS pasado como argumento se lee la fecha a la 
% que corresponde y busca, descarga y lee los archivos de productos IGS de
% tiempo real necesarios para realizar el procesamiento QRTPPP.
% 
% La estructura de carpetas final en pppdata será de la siguiente forma:
% ../pppdata/DDMMYYYY/EEEE/eeeeDOY0.YYo
%						  /SRTPPPInputData.mat
%						  /SRTPPPOutputData.mat
%					 /igsWWWWD.sp3
%					 / ... Demás productos
% 
% ARGUMENTOS:
%	rutaarchivorinexobs - Ruta completa del archivo de observables (respecto a
%						pppscripts)
% 
% DEVOLUCIÓN:
%	rutaarchivodatos	- Ruta completa del archivo con todos los datos para
%						realizar el SRTPPP del archivo pasado como argumento

SECONDS_IN_DAY = 24*60*60;

% filedir es: ../pppdata/DDMMYYYY/EEEE/
[pathstr,name,ext] = fileparts(rutaarchivorinexobs);
filedir = [pathstr '/'];
archivoRNX = [name '.mat'];

% Si el archivo ya había sido leído no vuelvo a leerlo, lo cargo
if ~exist([filedir archivoRNX],'file')
	disp('Leyendo datos RINEX_OBS')
	datosObsRNX = leerArchivoRINEX_OBS(rutaarchivorinexobs);
	save([filedir archivoRNX],'datosObsRNX');
	disp('Datos RINEX_OBS guardados')
else
	load([filedir archivoRNX]);
end

if isfield(datosObsRNX,'TimeFirstObs')
	tgps_first = datosObsRNX.TimeFirstObs;
	tgps_last = datosObsRNX.tR(end);
else
	tgps_first = datosObsRNX.tR(1);
	tgps_last = datosObsRNX.tR(end);
end

% Antes que nada detecto si estos datos ya están leídos y guardados en un .mat
% con el nombre final
archivodatos = 'SRTPPPInputData.mat';
rutaarchivodatos = [filedir archivodatos];

% Si los datos para PPP ya están leídos salgo
if exist([filedir archivodatos],'file')
	return;
end

[YYYY,MM,DD] = gpsTime2ymdhms(tgps_first);
tgps = ymdhms2gpsTime(YYYY,MM,DD,00,00,00);
[WWWWgps,TOWgps] = gpsTime2gpsWeekTOW(tgps);
DOWgps = fix(TOWgps/86400);

% Órbitas y relojes uso los archivos de la decodificación de los streams
archivosp3 = ['igc' num2str(WWWWgps,'%04u') num2str(DOWgps) '.sp3'];
archivoclk = ['igc' num2str(WWWWgps,'%04u') num2str(DOWgps) '.clk'];

% Descarga de los productos
filedir = rutaarchivorinexobs(1:20);

% Verifico que no exista el archivo actual.
if isempty(dir([filedir, archivosp3]))
    % Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
    [status, temp] = descargarArchivosGNSS({archivosp3}, filedir);
    rutaarchivosp3 = [filedir,temp{1}];
else
	rutaarchivosp3 = [filedir,archivosp3];
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


% Pero para los ERP tengo que suar los igu
[~,archivoserp{1},WWWW,DOW,HH] = generarNombresArchivosIGU(tgps_first);

% Calculo la fecha y hora de publicación de este primer archivo
tgpspub = gpsWeekTOW2gpsTime(WWWW,DOW*SECONDS_IN_DAY + (HH+3)*60*60);


% Ahora empiezo a avanzar de a 6 horas (el intervalo cada el que se publican
% nuevos productos precisos igu) y me fijo si sigo por detras del tiempo de la
% última medición
nn = 2;
tgpspub = tgpspub + 6*60*60;

while tgpspub < tgps_last
	
	[~,archivoserp{nn}] = generarNombresArchivosIGU(tgpspub);
	
	tgpspub = tgpspub + 6*60*60;
	nn = nn + 1;
	
end

% Descarga de los archivos IGU (productos ultra-rapid ERP)
NN = nn - 1;
descargadoserp = cell(NN,1);

for nn = 1:NN
	
	if isempty(dir([filedir, archivoserp{nn}]))
		% Si el archivo no existe lo descargo, y guardo el nombre nuevo en la variable.
		[status, temp] = descargarArchivosGNSS(archivoserp(nn), filedir);
		descargadoserp{nn,1} = [filedir temp{1}];
	else
		descargadoserp{nn,1} = [filedir archivoserp{nn}];
	end
	
end


% Lectura de los archivos

datosSP3 = leerArchivoSP3(rutaarchivosp3);
disp('Datos SP3 leídos')

datosSatCLK = leerArchivoCLK(rutaarchivoclk);
disp('Datos CLK leídos')

for nn = 1:NN
	datosERP(nn,1) = leerArchivoERP(descargadoserp{nn,1});
end
disp('Datos ERP leídos')

% Le agrego campos con los identificadores de tiempo
for nn = 1:NN
	
	% Obtengo el nombre del producto
	C = strsplit(descargadoserp{nn,1},'/');

	WWWW = str2double(C{end}(4:7));
	DOW = str2double(C{end}(8));
	HH = str2double(C{end}(10:11));
	tgpspub = gpsWeekTOW2gpsTime(WWWW,DOW*SECONDS_IN_DAY + (HH+3)*60*60);
	tgpsprediccion = gpsWeekTOW2gpsTime(WWWW,DOW*SECONDS_IN_DAY + HH*60*60);
	
	datosERP(nn,1).TiempoPublicacion = tgpspub;
	datosERP(nn,1).TiempoInicioPrediccion = tgpsprediccion;
	
end
	
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


save(rutaarchivodatos,	'datosObsRNX','datosSP3','datosSatCLK','datosERP', ...
						'datosSatATX','datosRecATX');

disp('Datos SRTPPP guardados')

end




%-------------------------------------------------------------------------------
function [archivossp3,archivoserp,WWWW,DOW,HH] = generarNombresArchivosIGU(tgps)

SECONDS_IN_DAY = 24*60*60;

[WWWW,TOW] = gpsTime2gpsWeekTOW(tgps);
SOD = TOW - fix(TOW/SECONDS_IN_DAY)*SECONDS_IN_DAY;
hh = fix(SOD/3600);
DOW = fix(TOW/SECONDS_IN_DAY);

% Genero el nombre del primero de los archivos necesarios (el de la 1ra época)
if hh < 3
	DOW = DOW - 1;
	HH = 18;
	if DOW < 0
		WWWW = WWWW - 1;
		DOW = 6;
	end	
elseif hh < 9
	HH = 00;
elseif hh < 15
	HH = 06;
elseif hh < 21
	HH = 12;
else
	HH = 18;
end

archivossp3 = ['igu' num2str(WWWW,'%04u') num2str(DOW) '_' num2str(HH,'%02u') '.sp3'];
archivoserp = ['igu' num2str(WWWW,'%04u') num2str(DOW) '_' num2str(HH,'%02u') '.erp'];

end
%-------------------------------------------------------------------------------