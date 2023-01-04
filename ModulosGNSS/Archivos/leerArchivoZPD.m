function [datosZPD] = leerArchivoZPD(archivozpd)
%LEERARCHIVOZPD Lee un archivo de soluciones troposféricas
% Devuelve una estructura con los datos de un archivo de soluciones 
% troposféricas provisto por el IGS en formato SINEX_TRO
% 
% ARGUMENTOS:
%	archivozpd	- Nombre del archivo ZPD.
%
% DEVOLUCIÓN:
%	datosZPD	- Estructura con los datos extraidos


% Apertura del archivo
if (exist(archivozpd,'file') == 2)
    fid = fopen(archivozpd,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivozpd), 'ERROR!');
end

datosZPD = struct('Producto','ZPD','data',[],'col',[]);
datosZPD.col.TGPS = 1;

tline = fgetl(fid);

field = [];

while isempty(strfind(tline,'+TROP/SOLUTION'))
	
	if ~isempty(strfind(tline,'SOLUTION_FIELDS_1'))
		% Obtengo los campos de la solución
		campos = textscan(tline(31:end),'%s');
		CC = length(campos{1});
		for cc = 1:CC
			
			% Si son desv.est. de la columna anterior le agrego el nombre
			if strcmp(campos{1}{cc},'STDDEV')
				field = [field campos{1}{cc}];
			else
				field = campos{1}{cc};
			end
			
			datosZPD.col.(field) = 1 + cc;
		end	

	elseif ~isempty(strfind(tline,'+TROP/STA_COORDINATES'))
		
		tline = fgetl(fid);
		tline = fgetl(fid);
		datosZPD.Estacion = tline(2:5);
		datosZPD.Posicion = sscanf(tline(16:54),'%f');

	end
	
	tline = fgetl(fid);
	
end

% Leo la linea del encabezado
tline = fgetl(fid);

% Asigno espacio para un día de datos con un muestro cada 300 s
datos = NaN(0,CC+1);

fin_datos = 0;

% Leo el grueso de los datos
while fin_datos == 0
	
	% Asigno espacio para un día de datos con un muestro cada 300 s
	valores = NaN(288,CC+1);
	ii = 1;
	
	while ii <= 288
		
		tline = fgetl(fid);
		
		% Si se terminaron los datos salgo del while y armo la matriz final
		if ~isempty(strfind(tline,'-TROP/SOLUTION')) || feof(fid)
			fin_datos = 1;
			break;
		end
		
		YYYY = 2000 + str2double(tline(7:8));
		DOY = str2double(tline(10:12));
		SOD = str2double(tline(14:18));
		
		[hh,mm,ss] = sod2hms(SOD);
		
		[DD,MM] = doy2daymonth(YYYY,DOY);
		
		tgps = utcTime2gpsTime(YYYY,MM,DD,hh,mm,ss);
		
		valores(ii,:) = [tgps sscanf(tline(19:end),'%f')'];
		
		ii = ii + 1;
				
	end
	
	datos = [datos; valores(1:ii-1,:)];
	
end


% Paso los retardos de [mm] a [m]
for cc = 1:CC
	if strcmp(campos{1}{cc},'TROTOT') || strcmp(campos{1}{cc},'TROTOTSTDDEV') || ...
		strcmp(campos{1}{cc},'TGNTOT') || strcmp(campos{1}{cc},'TGNTOTSTDDEV') || ...
		strcmp(campos{1}{cc},'TGETOT') || strcmp(campos{1}{cc},'TGETOTSTDDEV') || ...
		strcmp(campos{1}{cc},'TROWET') || strcmp(campos{1}{cc},'TROWETSTDDEV')
		
		datos(:,cc+1) = datos(:,cc+1)./1E3;
		
	end
end

datosZPD.data = datos;

fclose(fid);

end

