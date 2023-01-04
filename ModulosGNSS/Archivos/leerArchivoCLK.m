function [satClkData, staClkData] = leerArchivoCLK(archivoclk)
%LEERARCHIVOCLK Lee un archivo RINEX de correcciones de reloj
% Devuelve los datos de sesgos de reloj de satélites y de estaciones GNSS 
% tomados de un archivo tanto en formato .clk como .clk_30s
% 
% ARGUMENTOS:
%	archivoclk	- Nombre del archivo CLK a leer
% 
% DEVOLUCIÓN:
%	satClkData	- Estructura con los datos de reloj de satélites GNSS. Contiene
%				una matriz de datos de columnas preestablecidas, estas se listan
%				en la subestructura col.
%	staClkData	- Estructura con los datos de reloj de estaciones GNSS. Contiene
%				una matriz de celdas de columnas preestablecidas, estas se 
%				listan en la subestructura col.

% Abrir el archivo
if (exist(archivoclk,'file') == 2)
    fid = fopen(archivoclk,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivoclk), 'ERROR!');
end

tline = fgetl(fid);

if tline(21) == 'C'
	satClkData.Producto = 'CLK';
	staClkData.Producto = 'CLK';
else
	error('El archivo no es formato RINEX_CLK');
end
satClkData.data = zeros(0,4);
satClkData.col.TGPS = 1;
satClkData.col.GNSS = 2;
satClkData.col.PRN = 3;
satClkData.col.CLKERR = 4;
satClkData.col.CLKSIGMA = 5;
		
headerend = [];

while (isempty(headerend) == 1)
	
	headerend = strfind(tline,'END OF HEADER');
	headerest = strfind(tline,'# OF SOLN STA / TRF');
	headerpcv = strfind(tline,'SYS / PCVS APPLIED');
	headerdcb = strfind(tline,'SYS / DCBS APPLIED');
	headerobs = strfind(tline,'SYS / # / OBS TYPES');
	
	if ~isempty(headerpcv) || ~isempty(headerdcb) || ~isempty(headerobs)
		if strcmp(tline(1),'G')			% GPS
			gnssref = SistemaGNSS.GPS;
		elseif strcmp(tline(1),'R')		% GLONASS
			gnssref = SistemaGNSS.GLONASS;
		elseif strcmp(tline(1),'E')		% GALILEO
			gnssref = SistemaGNSS.Galileo;
		elseif strcmp(tline(1),'C')		% COMPASS
			gnssref = SistemaGNSS.BeiDou;
		elseif strcmp(tline(1),'J')		% QZSS
			gnssref = SistemaGNSS.QZSS;
		elseif strcmp(tline(1),'S')		% SBAS
			gnssref = SistemaGNSS.SBAS;
		end
	else
		gnssref = SistemaGNSS.GPS;
	end
	
	if ~isempty(headerest)
		nro_est = str2double(tline(1:6));
		
		staClkData.estaciones = cell(nro_est,5);
		staClkData.data = cell(0,5);		
		staClkData.col.TGPS = 1;
		staClkData.col.GNSS = 2;
		staClkData.col.STA = 3;
		staClkData.col.CLKERR = 4;
		staClkData.col.CLKSIGMA = 5;

		% Leo todas las estaciones disponibles
		for ii = 1:nro_est
			tline     = fgetl(fid);
			headerest = strfind(tline,'SOLN STA NAME / NUM');
			
			if (isempty(headerest) == 0)
				
				nombre_est = tline(1:4);
				codigo_est = tline(6:25);
				x_est = str2double(tline(26:36))/1000;
				y_est = str2double(tline(38:48))/1000;
				z_est = str2double(tline(50:60))/1000;
				
				staClkData.estaciones{ii,1} = nombre_est;
				staClkData.estaciones{ii,2} = codigo_est;
				staClkData.estaciones{ii,3} = x_est;
				staClkData.estaciones{ii,4} = y_est;
				staClkData.estaciones{ii,5} = z_est;
				
			end
		end
	end
	
	tline = fgetl(fid);
	
end

% Recorro cada entrada de datos
kk = 1;
jj = 1;

while ~feof(fid)

	tline = pad(fgetl(fid),80);
	
	% Datos de una estación
	if strcmp(tline(1:2),'AR')
		
		staClkData.data{kk,3} = tline(4:7);

% FIXME: En teoría el archivo debería decir en el el header a que GNSS está 
% referido. Si es un archivo GPS puro (lo debería especificar la primera línea
% del header pero se lo pasan por el orto) entonces el tiempo de la época es GPS

		% Carga del tiempo GPS en formato YYYY MM DD hh mm ss
		YY = str2double(tline(9:12));
		MM = str2double(tline(14:15));
		DD = str2double(tline(17:18));
		hh = str2double(tline(20:21));
		mm = str2double(tline(23:24));
		ss = str2double(tline(26:34));
		
		tgps = ymdhms2gpsTime(YY,MM,DD,hh,mm,ss);
		
		nro_datos = str2double(tline(35:37));
		
		clock_bias = str2double(tline(41:59));
		clock_bias_sigma = str2double(tline(61:79));

		staClkData.data{kk,1} = tgps;
		staClkData.data{kk,2} = gnssref;
		staClkData.data{kk,4} = clock_bias;
		staClkData.data{kk,5} = clock_bias_sigma;
		
		
		% Si se dan datos de drift y aceleración en la siguiente línea
		% los leo y no los cargo (al menos por ahora)
		if nro_datos > 2
			tline = fgetl(fid);
		end
		
		kk = kk + 1;
		
	end
	
	% Datos de un satélite
	if strcmp(tline(1:2),'AS')
		
		if strcmp(tline(4),'G')			% GPS
			gnss = SistemaGNSS.GPS;
		elseif strcmp(tline(4),'R')		% GLONASS
			gnss = SistemaGNSS.GLONASS;
		elseif strcmp(tline(4),'E')		% GALILEO
			gnss = SistemaGNSS.Galileo;
		elseif strcmp(tline(4),'C')		% COMPASS
			gnss = SistemaGNSS.BeiDou;
		elseif strcmp(tline(4),'J')		% QZSS
			gnss = SistemaGNSS.QZSS;
		elseif strcmp(tline(4),'S')		% SBAS
			gnss = SistemaGNSS.SBAS;
		end
				
		PRN = str2double(tline(5:6));
		
				% Carga del tiempo GPS en formato YYYY MM DD hh mm ss
		YY = str2double(tline(9:12));
		MM = str2double(tline(14:15));
		DD = str2double(tline(17:18));
		hh = str2double(tline(20:21));
		mm = str2double(tline(23:24));
		ss = str2double(tline(26:34));
		
		tgps = ymdhms2gpsTime(YY,MM,DD,hh,mm,ss);
		
		nro_datos = str2double(tline(35:37));
		
		clock_bias = str2double(tline(41:59));
		clock_bias_sigma = str2double(tline(61:79));
		
		satClkData.data(jj,1) = tgps;
		satClkData.data(jj,2) = gnss;
		satClkData.data(jj,3) = PRN;
		satClkData.data(jj,4) = clock_bias;
		satClkData.data(jj,5) = clock_bias_sigma;
		
		% Si se dan datos de drift y aceleración en la siguiente línea
		% los leo y no los cargo (al menos por ahora)
		if nro_datos > 2
			tline = fgetl(fid);
		end
		
		jj = jj + 1;
		
	end
		
end

fclose(fid);

end

