function [datosSP3] = leerArchivoSP3(archivosp3)
%LEERARCHIVOSP3 Lee un archivo de datos SP3 y devuelve una estructura
%   A partir de un archivo de navegaci�n del IGS en formato SP3 devuelve
%   la posici�n de los sat�lites observados.
%
%	PARAMETROS:
%	archivosp3	- Nombre del archivo de datos de posici�n
%
%	DEVOLUCION:
%	datosSP3	- Estructura de dos campos, uno con los identificadores de
%				cada columna, otra con los datos de cada instante de posici�n.
%				Los datos tienen el siguiente formato:
%				[TGPS PRN X Y Z CLKERR]
%				Donde X, Y, Z son las coordenadas del sat�lite en el marco
%				ECEF expresadas en [m] y CLKERR es el error de reloj
%				del sat�lite expresado en [s] (NO son las unidades usadas por el
%				formato SP3)

datosSP3 = [];

% Abrir el archivo y verificar correcta apertura
fid=fopen(archivosp3);
if fid == -1
	error('Error al abrir el archivo SP3especificado!');
end

% Recorre el encabezado del archivo (22 l�neas, la siguiente es la primera
% de datos)
for ii = 1:23
	tline = fgetl(fid);
	% Me fijo que sistema fue utilizado
	if ii == 1
		SYS = tline(47:51);
	end
	% Guardo la cantidad de sat�lites en el archivo SP3
	if ii == 3
		tline = tline(2:length(tline));
		F = sscanf(tline,'%u');
		JJ = F(1);
	end
end


% Recorro cada conjunto de observaciones
end_of_file = 0;
ii = 0;

while end_of_file ~= 1
	tline = tline(3:length(tline));
	F = sscanf(tline,'%f');
	% Carga del tiempo GPS gregoriano en variables y c�lculo de la semana y
	% el tiempo de la semana GPS
	YYYY = F(1);
	MM = F(2);
	DD = F(3);
	hh = F(4);
	mm = F(5);
	ss = F(6);
		
	tgps = ymdhms2gpsTime(YYYY,MM,DD,hh,mm,ss);
	
	% Guardo los datos de cada sat�lite y su PRN
	for jj = 1:JJ
		
		tline = fgetl(fid);
		
		tline = tline(3:length(tline));
		F = sscanf(tline,'%f');
		
		PRN = F(1); x = F(2); y = F(3); z = F(4); dtj = F(5);
				
		% Creo el vector de datos de observaci�n
		datos(ii+jj,:) = [tgps PRN x y z dtj];
		
	end
	
	% Leo la siguiente l�nea y verifico si se lleg� al fin de archivo
	tline = fgetl(fid);
	if strfind(tline,'EOF')
		end_of_file = 1;
	end
	
	ii = ii + jj;
	
end

% Elimino las filas de la matriz que posean datos de posici�n y reloj dudosos
datos_erroneos = (	(datos(:,3) == 0) | ...
					(datos(:,4) == 0) | ...
					(datos(:,5) == 0) |  ...
					(datos(:,6) == 999999.999999));
datos(datos_erroneos,:) = [];

% Paso las coordenadas de [km] a [m] y los relojes de [us] a [s]
datos(:,3) = datos(:,3)*1000;
datos(:,4) = datos(:,4)*1000;
datos(:,5) = datos(:,5)*1000;
datos(:,6) = datos(:,6)/1E6;

%Guardo los datos en la estructura de salida y numero las columnas
datosSP3.Producto = 'SP3';
datosSP3.data = datos;
datosSP3.col.TGPS = 1;
datosSP3.col.PRN = 2;
datosSP3.col.X = 3;
datosSP3.col.Y = 4;
datosSP3.col.Z = 5;
datosSP3.col.CLKERR = 6;
datosSP3.sys = SYS;

fclose(fid);

end

