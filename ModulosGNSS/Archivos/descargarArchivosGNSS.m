function [ fileMask, fileNames ] = descargarArchivosGNSS( fileList, saveDir )
%DESCARGARARCHIVOGNSS Descarga los archivos solicitados en la lista fileList.
%%-------------------------------------------------------------------------
% Ya que esta hecho el generador de nombres, espero un arreglo de celdas 
% con los nombres de archivos a descargar, la funcion reconoce el tipo de
% medicion que se requiere genera los links correspondientes.
% 
% Tipos de archivos soportados:
% * .clk	- Nombre del archivo CLK
% * .n		- Nombre del archivo RINEX_NAV
% * .o		- Nombre del archivo RINEX_OBS
% * .snx	- Nombre del archivo SINEX
% * .zpd	- Nombre del archivo SINEX_TRO
% * .sp3	- Nombre del archivo SP3 de orbitas precisas.
% * .erp	- Nombre del archivo ERP
% 
% El segundo parametro corresponde con el directorio donde almacenar los
% datos.
%
% La funcion devuelve una mascara booleana con el resultado de la descarga.
% 0 - No se pudo descargar ese archivo.
% 1 - Se descargo correctamente.
%
% Y un arreglo de celdas con los nombres de los archivos descargados.
% -------------------------------------------------------------------------

% Primero genero el directorio donde se encuentra el script de bash para la
% descarga. Esto depende de si se trabaja en Windows (deberá convertirse a una
% dirección compatible con el WSL) o en Linux directamente
if isunix
	dirScriptDescarga = which('descargarArchivoGNSS.sh');
elseif ispc
	partes = split(which('descargarArchivoGNSS.sh'),'\');
	dirScriptDescarga = ['/mnt/' lower(partes{1}(1))];
	for indx = 2:length(partes)
		dirScriptDescarga = [dirScriptDescarga '/' partes{indx}];
	end
end		
	
				
% CDDIS Archive:
cddisArchive = 'https://cddis.nasa.gov/archive';

fileMask = false(length(fileList(:,1)), 1);
fileNames = cell(length(fileList(:,1)), 1);

% Recorro la lista y llamo a la funcion de descarga correspondiente.
for k = 1:length(fileMask)
	% Obtengo la extensión del archivo.
	file = fileList{k};
	tokens = strsplit(file, '.');
	extension = tokens{length(tokens)};
	mask = find(isletter(extension), 1);
	extension = extension(mask:end);
	
	% En caso de llamada con clk de 30s corrijo el nombre.
	if strcmp(extension,'clk_30s')
		extension = 'clk';
		file = file(1:length(file) - 4);
	end
	
	% Segun el caso:
	switch(extension)
		case 'n'
			%Archivo de Navegacion.
			doyStr = file(5:7);
			yyStr = file(10:11);
			yyyyStr = ['20', yyStr];
			
			% Genero la direccion del archivo y cambio de directorio.
			dirNav = ['/gnss/data/daily/', yyyyStr, '/', doyStr, '/', yyStr, 'n/'];
			
			% Genero el nombre del archivo.
			fileNames{k} = file;
			currFile = [file, '.Z'];
			
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirNav];
			
			%Intento descargar el archivo.
			fprintf('NAV: %s - ', currFile);
			try				
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
			
		case 'o'
			%Archivo de Observables RINEX V2
			doyStr = file(5:7);
			yyStr = file(10:11);
			yyyyStr = ['20', yyStr];
			
			% Genero la direccion del archivo y cambio de directorio.
			dirObs = ['/gnss/data/daily/', yyyyStr, '/', doyStr, '/', yyStr, 'o/'];
			
			% Genero el nombre del archivo.						
			fileNames{k} = file;
			currFile = [file, '.Z'];
						
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirObs];
			
			%Intento descargar el archivo.
			fprintf('OBS: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
			
		case 'sp3'
			%Archivo de Orbitas precisas.
			weekStr = file(4:7);
			
			% Genero la direccion del archivo, teniendo en cuenta si son 
			% productos real-time (decodificación de streamings)
			if strcmp(file(1:3),'igc') || strcmp(file(1:3),'igt') || strcmp(file(1:3),'rit')
				dirSp3 = ['/gnss/products/rtpp/', weekStr, '/'];
			else
				dirSp3 = ['/gnss/products/', weekStr, '/'];
			end
						
			%Intento descargar el archivo.
			fileNames{k} = file;
			currFile = [file, '.Z'];
			
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirSp3];
			
			fprintf('SP3: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end

		case 'erp'
			%Archivo de Orbitas precisas.
			weekStr = file(4:7);
			
			% Genero la direccion del archivo y cambio de directorio.
			dirSp3 = ['/gnss/products/', weekStr, '/'];
			
			%Intento descargar el archivo.
			fileNames{k} = file;
			currFile = [file, '.Z'];
			
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirSp3];
			
			fprintf('ERP: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
			
		case 'clk'
			%Archivo de Reloj.
			weekStr = file(4:7);
			
			% Genero la direccion del archivo y cambio de directorio, teniendo 
			% en cuenta si son productos real-time (decodificación de 
			% streamings)
			if strcmp(file(1:3),'igc') || strcmp(file(1:3),'igt') || strcmp(file(1:3),'rit')
				dirClk = ['/gnss/products/rtpp/', weekStr, '/'];
			else
				dirClk = ['/gnss/products/', weekStr, '/'];
			end
			
			% En primer lugar intento descargar un archivo de relojes cada 30
			% segundos si es que lo hay
			currFile = [file, '_30s.Z'];
						
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirClk];
			
			%Intento descargar el archivo.
			fprintf('CLK: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				if ejecutarComandoLinux(comando)
					% Si falló ntento descargar uno de menor tasa
					currFile = [file, '.Z'];
					fileDir = [cddisArchive dirClk];
					comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
					ejecutarComandoLinux(comando);
				end
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			fileNames{k} = currFile(1:length(currFile) - 2);
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
		
		case 'zpd'
			%Archivo de soluciones troposféricas
			
			doyStr = file(5:7);
			yyStr = file(10:11);
			yyyyStr = ['20', yyStr];
			
			% Genero la direccion del archivo
			dirZpd = ['/gnss/products/troposphere/zpd/', yyyyStr, '/', doyStr, '/'];
					
			% Genero el nombre del archivo.
			fileNames{k} = file;
			currFile = [file, '.gz'];
			
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirZpd];
			
			%Intento descargar el archivo.
			fprintf('ZPD: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
			%break
			
		case 'snx'
			%Archivo de soluciones SINEX
			weekStr = file(7:10);
			
			% Genero la direccion del archivo y cambio de directorio.
			dirSnx = ['/gnss/products/', weekStr, '/'];
						
			%Intento descargar el archivo.
			fileNames{k} = file;
			currFile = [file, '.Z'];
			
			% Genero la dirección completa para la descarga
			fileDir = [cddisArchive dirSnx];
			
			fprintf('SNX: %s - ', currFile);
			try
				comando = [dirScriptDescarga ' ' saveDir ' ' fileDir ' ' currFile];
				ejecutarComandoLinux(comando);
				result = true;
			catch
				% En caso de error.
				fprintf('[ERROR]\nEl archivo %s no se encuentra disponible.\n\n', currFile);
				result = false;
			end
			
			% Si se descargo exitosamente, lo informo en la consola.
			if result == true
				fprintf('[Descarga OK]\n');
			end
			%break
			
		otherwise
			%Archivo de desconocido.
			fprintf('No se recononce el archivo %s\n', file);
			result = false;
	end
	% Agrego a la lista de salida.
	fileMask(k) = result;
end

% % % % Genero una lista de los archivos comprimidos descargados.
% % % files1 = dir([saveDir, '*.Z']);
% % % files2 = dir([saveDir, '*.gz']);
% % % files = [files1; files2];
% % % 
% % % % Recorro la lista y descomprimo los archivos.
% % % for k = 1:numel(files)
% % % 	
% % % 	% Esquivo archivos comprimidos que no sean de productos descargados ahora
% % % 	% (e.g. archivos de datos de GRACE)
% % % 	if ~isempty(strfind(files(k).name,'grace'))
% % % 		continue;
% % % 	end
% % % 	
% % % 	uncompress([saveDir, files(k).name]);
% % % 	
% % % end

end