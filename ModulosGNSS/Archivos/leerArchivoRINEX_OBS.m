function [datosObs] = leerArchivoRINEX_OBS(archivoobs)
%LEERARCHIVORINEX_OBS Lee un archivo RINEX (formato 2.11 o 3.01) de observables
% 
% ARGUMENTOS:
%	archivoobs	- Nombre del archivo a leer
% 
% DEVOLUCIÓN:
%	datosObs	- Estructura con los datos leídos


% Abro el archivo
if (exist(archivoobs,'file') == 2)
    fid = fopen(archivoobs,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivoobs), 'ERROR!');
end

% Leo el encabezado
[datosObs,RINEX_VER,RINEX_TIPO,RCV_CLK,KKMAX] = leerEncabezadoRINEX_OBS(fid);

kk = 0;

% Leo las mediciones de cada época
while ~feof(fid)

	kk = kk + 1;
	
	if RINEX_VER == 2
		datosObs = leerEpocaRINEX2(fid,datosObs,kk,RCV_CLK,RINEX_TIPO);
	elseif RINEX_VER == 3
		datosObs = leerEpocaRINEX3(fid,datosObs,kk,RCV_CLK,RINEX_TIPO);
	end

	% Si llegué al límite de memoria y el archivo continua asigno más
	if (kk == KKMAX) && ~feof(fid)
		
		warning('Limite de entradas alcanzado, extendiendo memoria');
		[datosObs,KKMAX] = extenderMemoriaAsignada(datosObs);
		
	end	
end

% Si el archivo era RINEX 2 elimino las estructuras de los GNSS no presentes
if RINEX_VER == 2 && RINEX_TIPO == 'M'
	datosObs = eliminarEstructurasSobrantesRINEX2(datosObs);
end

% Elimino las entradas que sobraron de la asignación de memoria
datosObs = recortarMemoriaAsignada(datosObs,kk);

% Paso las mediciones de fases de portadora de [ciclos] a [m]
datosObs = convertirFasesCiclosAMetros(datosObs);

% Cierro el archivo
fclose(fid);

end





%-------------------------------------------------------------------------------
function [datosObs,RINEX_VER,RINEX_TIPO,RCV_CLK,KKMAX] = leerEncabezadoRINEX_OBS(fid)

% Alojamiento inicial máximo de memoria para 24 horas de mediciones a tasa de 1 segundo
KKMAX = 24*60*60;

RCV_CLK = false;

tline = fgetl(fid);

while isempty(strfind(tline,'END OF HEADER'))
	
	if ~isempty(strfind(tline,'RINEX VERSION / TYPE'))
		datosObs.Version = str2double(tline(1:9));
		RINEX_VER = fix(datosObs.Version);
		RINEX_TIPO = tline(41);
	

	elseif ~isempty(strfind(tline,'MARKER NAME'))
		
		datosObs.Estacion = strtrim(tline(1:60));
		

	elseif ~isempty(strfind(tline,'REC # / TYPE / VERS'))
		
		datosObs.Receptor = strtrim(tline(21:40));
		

	elseif ~isempty(strfind(tline,'ANT # / TYPE'))
		
		datosObs.Antena = strtrim(tline(21:35));
		datosObs.Domo = strtrim(tline(37:40));
		

	elseif ~isempty(strfind(tline,'APPROX POSITION XYZ'))
	
		datosObs.PosicionAprox = sscanf(tline,'%f');
		
	
	elseif ~isempty(strfind(tline,'ANTENNA: DELTA H/E/N'))
		
		datosObs.OffsetARP = [str2double(tline(15:28)); str2double(tline(29:42)); str2double(tline(1:14))];
		
	
	elseif ~isempty(strfind(tline,'TIME OF FIRST OBS'))
		
		firstobs = sscanf(tline(1:43),'%d %d %d %d %d %f');
		gnss = tline(49:51);
		if strcmp(gnss,'GPS')
			datosObs.TimeFirstObs = ymdhms2gpsTime(firstobs(1),firstobs(2),firstobs(3),firstobs(4),firstobs(5),firstobs(6));
		elseif strcmp(gnss,'UTC')
			datosObs.TimeFirstObs = utcTime2gpsTime(firstobs(1),firstobs(2),firstobs(3),firstobs(4),firstobs(5),firstobs(6));
		else
			warning('Tiempo de GNSS no soportado aún)');
		end
		
		
	elseif ~isempty(strfind(tline,'RCV CLOCK OFFS APPL'))
		
		RCV_CLK = str2double(tline(1:6));	% Flag de correcciones de reloj
		
	
	elseif ~isempty(strfind(tline,'# / TYPES OF OBSERV'))	% RINEX 2.11 !!
	
		NUM_OBS = str2double(tline(1:6));
		
		codigos_obs = cell(NUM_OBS,1);
		
		if NUM_OBS <= 9
			for nn = 1:NUM_OBS
				codigos_obs{nn} = strtrim(tline(7+(nn-1)*6:7+nn*6-1));
			end
		else
			% Leo las líneas completas que haya
			for mm = 1:fix(NUM_OBS/9)
				for nn = 1:9
					codigos_obs{(mm-1)*9+nn} = strtrim(tline(7+(nn-1)*6:7+nn*6-1));
				end
				tline = fgetl(fid);
			end
			
			% Y luego las que queden en una línea aparte
			for nn = 1:mod(NUM_OBS,9)
				codigos_obs{mm*9+nn} = strtrim(tline(7+(nn-1)*6:7+nn*6-1));
			end
		end
		
		datosObs = generarEstructuras(datosObs,codigos_obs,NUM_OBS,RINEX_VER,RINEX_TIPO,KKMAX);
		
	elseif ~isempty(strfind(tline,'SYS / # / OBS TYPES'))	% RINEX 3.01 !!
		
		GNSS = tline(1);
		NUM_OBS = str2double(tline(4:6));
	
		codigos_obs = cell(NUM_OBS,1);
		
		if NUM_OBS <= 13
			for nn = 1:NUM_OBS
				codigos_obs{nn} = strtrim(tline(7+(nn-1)*4:7+nn*4-1));
			end
		else
			% Leo las líneas completas que haya
			for mm = 1:fix(NUM_OBS/13)
				for nn = 1:13
					codigos_obs{(mm-1)*13+nn} = strtrim(tline(7+(nn-1)*4:7+nn*4-1));
				end
				tline = fgetl(fid);
			end
			
			% Y luego las que queden en una línea aparte
			for nn = 1:mod(NUM_OBS,13)
				codigos_obs{mm*13+nn} = strtrim(tline(7+(nn-1)*4:7+nn*4-1));
			end
		end
		
		datosObs = generarEstructuras(datosObs,codigos_obs,NUM_OBS,RINEX_VER,RINEX_TIPO,KKMAX,GNSS);
		
	elseif ~isempty(strfind(tline,'GLONASS SLOT / FRQ #'))	% RINEX 3.01 !!
		
		NUM_SLOTS = str2double(tline(1:3));
		
		datosObs.GlonassSlotFreq = zeros(9,2);
		
		if NUM_SLOTS <= 8
			for nn = 1:NUM_SLOTS
				datosObs.GlonassSlotFreq(nn,1) = str2double(tline(6+(nn-1)*7:7+(nn-1)*7));
				datosObs.GlonassSlotFreq(nn,2) = str2double(tline(9+(nn-1)*7:10+(nn-1)*7));
			end
		else
			% Leo las líneas completas que haya
			for mm = 1:fix(NUM_SLOTS/8)
				for nn = 1:8
					datosObs.GlonassSlotFreq((mm-1)*8+nn,1) = str2double(tline(6+(nn-1)*7:7+(nn-1)*7));
					datosObs.GlonassSlotFreq((mm-1)*8+nn,2) = str2double(tline(9+(nn-1)*7:10+(nn-1)*7));
				end
				tline = fgetl(fid);
			end
			
			% Y luego las que queden en una línea aparte
			for nn = 1:mod(NUM_SLOTS,8)
				datosObs.GlonassSlotFreq(mm*8+nn,1) = str2double(tline(6+(nn-1)*7:7+(nn-1)*7));
				datosObs.GlonassSlotFreq(mm*8+nn,2) = str2double(tline(9+(nn-1)*7:10+(nn-1)*7));
			end
		end
	end

	tline = fgetl(fid);
	
end

% Agrego el campo con los tiempos de recepción, el de los sistemas presentes
% y el de los posibles eventos
datosObs.tR = NaN(KKMAX,1);
datosObs.Eventos = NaN(KKMAX,1);
if RINEX_VER == 2
	datosObs.GNSS = [];
end

% Si hay correcciones de reloj de receptor agrego el campo
if RCV_CLK
	datosObs.RelojReceptor = NaN(KKMAX,1);
end

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function datosObs = leerEpocaRINEX2(fid,datosObs,kk,RCV_CLK,RINEX_TIPO)

tline = fgetl(fid);
while ~isempty(strfind(tline,'COMMENT'))
	tline = fgetl(fid);
end

% Si ya no quedaban más épocas salgo
if feof(fid)
	return;
end

% Leo el encabezado de la época
event_flag = str2double(tline(27:29));

% Si no hay evento extraño (a lo sumo falla de alimentación) leo normalmente
if event_flag <= 1
	
	% Tiempo de la época
	t = (sscanf(tline(1:26),'%f'))' + [2000 0 0 0 0 0];
	if RINEX_TIPO == 'R'
		datosObs.tR(kk,1) = utcTime2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
	else
		datosObs.tR(kk,1) = ymdhms2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
	end
	
	% Flag de evento
	datosObs.Eventos(kk,1) = event_flag;
	
	% Cantidad de satélites presentes
	NSAT = str2double(tline(30:32));
	
	GNSS = repmat(SistemaGNSS.UNKNOWN_GNSS,NSAT,1);
	PRN = NaN(NSAT,1);
		
	if RCV_CLK
			datosObs.RelojReceptor(kk,1) = str2double(tline(69:80));
	end

	if NSAT <= 12
		% Están todos en una línea
		for jj = 1:NSAT
			GNSS(jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
			PRN(jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
		end
	else
		% Leo las líneas completas que haya
		for mm = 1:fix(NSAT/12)
			for jj = 1:12
				GNSS((mm-1)*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
				PRN((mm-1)*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
			end
			if (mod(NSAT,12) ~= 0) || ((mod(NSAT,12) == 0) && (mm < fix(NSAT/12)))
				tline = fgetl(fid);
			end
		end
		
		% Y luego las que queden en una línea aparte
		for jj = 1:mod(NSAT,12)
			GNSS(mm*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
			PRN(mm*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
		end
	end

	% Una vez que tengo la lista de satélites leo las mediciones
	NOBS = length(datosObs.(sistemaGNSS2stringEstructura(GNSS(1))).Observables);
		
	for jj = 1:NSAT
		
		tline = pad(fgetl(fid),80);
		
		gnss_field = sistemaGNSS2stringEstructura(GNSS(jj));
		prn_col = PRN(jj);
			
		for mm = 1:fix(NOBS/5)
			for nn = 1:5
				codigo_field = char(datosObs.gpsObs.Observables((mm-1)*5+nn));
				
				datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(1+(nn-1)*16:14+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(15+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(16+(nn-1)*16));
			end
			if (mod(NOBS,5) ~= 0) || ((mod(NOBS,5) == 0) && (mm < fix(NOBS/5)))
				tline = pad(fgetl(fid),80);
			end
		end
		
		if isempty(mm)
			mm = 0;
		end
		
		% Y luego las que queden en una línea aparte
		for nn = 1:mod(NOBS,5)
			codigo_field = char(datosObs.gpsObs.Observables(mm*5+nn));
			
			datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(1+(nn-1)*16:14+(nn-1)*16));
			datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(15+(nn-1)*16));
			datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(16+(nn-1)*16));
		end	
		
	end
	
% Caso de un evento especial	
elseif (event_flag >= 2) && (event_flag <= 5)
	
	% Número de líneas especiales a leer
	NN =  str2double(tline(30:32));
	for nn = 1:NN
		tline = fgetl(fid);
	end
	
	% Si solo se especifica que el receptor se comenzó o terminó de mover leo
	% los datos como si fuera una época más:
	if (event_flag == 2) || (event_flag == 3)
		
		% La siguiente línea ya debería ser una entrada de observables
		tline = fgetl(fid);
	
		% Flag de evento
		datosObs.Eventos(kk,1) = event_flag;
	
		% Tiempo de la época
		t = (sscanf(tline(1:26),'%f'))' + [2000 0 0 0 0 0];
		datosObs.tR(kk,1) = ymdhms2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
		
		% Cantidad de satélites presentes
		NSAT = str2double(tline(30:32));
		
		GNSS = repmat(SistemaGNSS.UNKNOWN_GNSS,NSAT,1);
		PRN = NaN(NSAT,1);
		
		if RCV_CLK
			datosObs.RelojReceptor(kk,1) = str2double(tline(69:80));
		end

		if NSAT <= 12
			% Están todos en una línea
			for jj = 1:NSAT
				GNSS(jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
				PRN(jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
			end
		else
			% Leo las líneas completas que haya
			for mm = 1:fix(NSAT/12)
				for jj = 1:12
					GNSS((mm-1)*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
					PRN((mm-1)*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
				end
				if (mod(NSAT,12) ~= 0) || ((mod(NSAT,12) == 0) && (mm < fix(NSAT/12)))
					tline = fgetl(fid);
				end
			end
			
			if isempty(mm)
				mm = 0;
			end
			
			% Y luego las que queden en una línea aparte
			for jj = 1:mod(NSAT,12)
				GNSS(mm*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
				PRN(mm*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
			end
		end
		
		% Una vez que tengo la lista de satélites leo las mediciones
		NOBS = length(datosObs.(sistemaGNSS2stringEstructura(GNSS(1))).Observables);
		
		for jj = 1:NSAT
			
			tline = pad(fgetl(fid),80);
			
			gnss_field = sistemaGNSS2stringEstructura(GNSS(jj));
			prn_col = PRN(jj);
			
			for mm = 1:fix(NOBS/5)
				for nn = 1:5
					codigo_field = char(datosObs.(gnss_field).Observables((mm-1)*5+nn));
					
					datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(1+(nn-1)*16:14+(nn-1)*16));
					datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(15+(nn-1)*16));
					datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(16+(nn-1)*16));
				end
				if (mod(NOBS,5) ~= 0) || ((mod(NOBS,5) == 0) && (mm < fix(NOBS/5)))
					tline = pad(fgetl(fid),80);
				end
			end
			
			if isempty(mm)
				mm = 0;
			end
			
			% Y luego las que queden en una línea aparte
			for nn = 1:mod(NOBS,5)
				codigo_field = char(datosObs.(gnss_field).Observables(mm*5+nn));
				
				datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(1+(nn-1)*16:14+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(15+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(16+(nn-1)*16));
			end
			
		end
	end
	
% Reporte de saltos de ciclo (no lo guardo, solo leo las líneas)
elseif event_flag == 6
	
	% Cantidad de satélites presentes
	NSAT = str2double(tline(30:32));
	
	GNSS = repmat(SistemaGNSS.UNKNOWN_GNSS,NSAT,1);
	PRN = NaN(NSAT,1);
	
	if NSAT <= 12
		% Están todos en una línea
		for jj = 1:NSAT
			GNSS(jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
			PRN(jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
		end
	else
		% Leo las líneas completas que haya
		for mm = 1:fix(NSAT/12)
			for jj = 1:12
				GNSS((mm-1)*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
				PRN((mm-1)*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
			end
			if (mod(NSAT,12) ~= 0) || ((mod(NSAT,12) == 0) && (mm < fix(NSAT/12)))
				tline = fgetl(fid);
			end
		end
		
		if isempty(mm)
			mm = 0;
		end
		
		% Y luego las que queden en una línea aparte
		for jj = 1:mod(NSAT,12)
			GNSS(mm*12+jj) = determinarSistemaGNSS(tline(33+(jj-1)*3));
			PRN(mm*12+jj) = str2double(tline(34+(jj-1)*3:35+(jj-1)*3));
		end
	end
	
	% Una vez que tengo la lista de satélites leo las mediciones
	NOBS = length(datosObs.(sistemaGNSS2stringEstructura(GNSS(1))).Observables);
	
	for jj = 1:NSAT
		
		tline = pad(fgetl(fid),80);
		
		for mm = 1:fix(NOBS/5)
			for nn = 1:5
			end
			if (mod(NOBS,5) ~= 0) || ((mod(NOBS,5) == 0) && (mm < fix(NOBS/5)))
				tline = pad(fgetl(fid),80);
			end
		end
		
		% Y luego las que queden en una línea aparte
		for nn = 1:mod(NOBS,5)
		end
		
	end
	
end

if event_flag <= 3
	% Devuelvo los sistemas presentes en la época
	GNSSs = unique(GNSS);
	datosObs.GNSS = unique([datosObs.GNSS; GNSSs]);
	
	% Guardo las listas de satélites presentes
	gpsPRN = PRN(GNSS == SistemaGNSS.GPS);
	glonassPRN = PRN(GNSS == SistemaGNSS.GLONASS);
	galileoPRN = PRN(GNSS == SistemaGNSS.Galileo);
	sbasPRN = PRN(GNSS == SistemaGNSS.SBAS);
	
	if ~isempty(gpsPRN)
		datosObs.gpsObs.Visibles{kk,1} = gpsPRN;
	end
	if ~isempty(glonassPRN)
		datosObs.glonassObs.Visibles{kk,1} = glonassPRN;
	end
	if ~isempty(galileoPRN)
		datosObs.galileoObs.Visibles{kk,1} = galileoPRN;
	end
	if ~isempty(sbasPRN)
		datosObs.sbasObs.Visibles{kk,1} = sbasPRN;
	end
end

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function datosObs = leerEpocaRINEX3(fid,datosObs,kk,RCV_CLK,RINEX_TIPO)

tline = fgetl(fid);
while isempty(strfind(tline,'>'))
	tline = fgetl(fid);
end

% Si ya no quedaban más épocas salgo
if feof(fid)
	return;
end

% Leo el encabezado de la época
event_flag = str2double(tline(30:32));

if event_flag <= 1
	
	% Tiempo de la época
	t = (sscanf(tline(3:29),'%f'))';
	if RINEX_TIPO == 'R'
		datosObs.tR(kk,1) = utcTime2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
	else
		datosObs.tR(kk,1) = ymdhms2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
	end
	
	% Flag de evento
	datosObs.Eventos(kk,1) = event_flag;
	
	% Cantidad de satélites presentes
	NSAT = str2double(tline(33:35));
	
	GNSS = repmat(SistemaGNSS.UNKNOWN_GNSS,NSAT,1);
	PRN = NaN(NSAT,1);
	
	% Si el archivo especifica correcciones de reloj las leo
	if RCV_CLK
		datosObs.RelojReceptor = [datosObs.RelojReceptor; str2double(tline(42:56))];
	end
	
	% Empiezo a recorrer cada satélite (una línea de largo variable por satélite)
	for jj = 1:NSAT
		
		tline = fgetl(fid);
		
		GNSS(jj) = determinarSistemaGNSS(tline(1));
		PRN(jj) = str2double(tline(2:3));
		
		gnss_field = sistemaGNSS2stringEstructura(GNSS(jj));
		prn_col = PRN(jj);
		
		NOBS = length(datosObs.(sistemaGNSS2stringEstructura(GNSS(jj))).Observables);
			
		% Completo el string con espacios para el caso en que haya mediciones 
		% faltantes poder leer igual
		tline = pad(tline,3+16*NOBS);
		
		for nn = 1:NOBS
			codigo_field = char(datosObs.(gnss_field).Observables(nn));
			
			datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(4+(nn-1)*16:17+(nn-1)*16));
			datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(18+(nn-1)*16));
			datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(19+(nn-1)*16));
		end
	
	end
	
% Caso de un evento especial	
elseif (event_flag >= 2) && (event_flag <= 5)
	
	% Número de líneas especiales a leer
	NN =  str2double(tline(30:32));
	for nn = 1:NN
		tline = fgetl(fid);
	end
	
	% Si solo se especifica que el receptor se comenzó o terminó de mover leo
	% los datos como si fuera una época más:
	if (event_flag == 2) || (event_flag == 3)	
	
		% Tiempo de la época
		t = (sscanf(tline(3:29),'%f'))';
		datosObs.tR(kk,1) = ymdhms2gpsTime(t(1),t(2),t(3),t(4),t(5),t(6));
		
		% Flag de evento
		datosObs.Eventos(kk,1) = event_flag;
		
		% Cantidad de satélites presentes
		NSAT = str2double(tline(33:35));
		
		GNSS = repmat(SistemaGNSS.UNKNOWN_GNSS,NSAT,1);
		PRN = NaN(NSAT,1);
		
		% Si el archivo especifica correcciones de reloj las leo
		if RCV_CLK
			datosObs.RelojReceptor = [datosObs.RelojReceptor; str2double(tline(42:56))];
		end
		
		% Empiezo a recorrer cada satélite (una línea de largo variable por satélite)
		for jj = 1:NSAT
			
			tline = fgetl(fid);
			
			GNSS(jj) = determinarSistemaGNSS(tline(1));
			PRN(jj) = str2double(tline(2:3));
			
			gnss_field = sistemaGNSS2stringEstructura(GNSS(jj));
			prn_col = PRN(jj);
			
			NOBS = length(datosObs.(sistemaGNSS2stringEstructura(GNSS(jj))).Observables);
			
			for nn = 1:NOBS
				codigo_field = char(datosObs.(gnss_field).Observables(nn));
				
				datosObs.(gnss_field).(codigo_field).Valor(kk,prn_col) = str2double(tline(4+(nn-1)*16:17+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).LLI(kk,prn_col) = str2double(tline(18+(nn-1)*16));
				datosObs.(gnss_field).(codigo_field).SSI(kk,prn_col) = str2double(tline(19+(nn-1)*16));
			end
			
		end
		
	end
		
% Reporte de saltos de ciclo (no lo guardo, solo leo las líneas)
elseif event_flag == 6
	
	% Cantidad de satélites presentes
	NSAT = str2double(tline(33:35));
		
	for nn = 1:NSAT
		tline = fgetl(fid);
	end
	
end

% Guardo las listas de satélites presentes
NSIS = length(datosObs.GNSS);
for ss = 1:NSIS
	gnss_field = sistemaGNSS2stringEstructura(datosObs.GNSS(ss));
	gnssPRN = PRN(GNSS == datosObs.GNSS(ss));
	if ~isempty(gnssPRN)
		datosObs.(gnss_field).Visibles{kk,1} = gnssPRN;
	end
end

end
%-------------------------------------------------------------------------------





%-------------------------------------------------------------------------------
function datosObs = generarEstructuras(datosObs,codigos,NUM_OBS,RINEX_VER,RINEX_TIPO,KKMAX,GNSS)

cellgps =		repmat({struct('Valor',NaN(KKMAX,32),	'LLI',NaN(KKMAX,32),	'SSI',NaN(KKMAX,32))}, 	NUM_OBS, 1);
cellglonass =	repmat({struct('Valor',NaN(KKMAX,24),	'LLI',NaN(KKMAX,24),	'SSI',NaN(KKMAX,24))}, 	NUM_OBS, 1);
cellgalileo =	repmat({struct('Valor',NaN(KKMAX,40),	'LLI',NaN(KKMAX,40),	'SSI',NaN(KKMAX,40))}, 	NUM_OBS, 1);
cellgeo =		repmat({struct('Valor',NaN(KKMAX,100),	'LLI',NaN(KKMAX,100),	'SSI',NaN(KKMAX,100))}, NUM_OBS, 1);
cellqzss =		repmat({struct('Valor',NaN(KKMAX,7),	'LLI',NaN(KKMAX,7),		'SSI',NaN(KKMAX,7))}, 	NUM_OBS, 1);
cellbds =		repmat({struct('Valor',NaN(KKMAX,35),	'LLI',NaN(KKMAX,35),	'SSI',NaN(KKMAX,35))}, 	NUM_OBS, 1);
cellirnss =		repmat({struct('Valor',NaN(KKMAX,7),	'LLI',NaN(KKMAX,7),		'SSI',NaN(KKMAX,7))}, 	NUM_OBS, 1);

% Si era formato RINEX 2.11 todos los GNSS tienen las mismas mediciones, genero 
% las estructuras dependiendo de que tipo de archivo sea
if RINEX_VER == 2
	
	codigos = convertirCodigosRINEX2aRINEX3(codigos);
	% Convierto los códigos (chars) a mediciones (TipoMedicion)
	CC = length(codigos);
	for cc = 1:CC
		mediciones(cc,1) = TipoMedicion.(codigos{cc});
	end
	
	if RINEX_TIPO == ' ' || RINEX_TIPO == 'G'
		datosObs.GNSS = SistemaGNSS.GPS;
		datosObs.gpsObs = cell2struct(cellgps,codigos,1);
		datosObs.gpsObs.Observables = mediciones;
		datosObs.gpsObs.Visibles = cell(KKMAX,0);
	elseif RINEX_TIPO == 'R'
		datosObs.GNSS = SistemaGNSS.GLONASS;
		datosObs.glonassObs = cell2struct(cellglonass,codigos,1);
		datosObs.glonassObs.Observables = mediciones;
		datosObs.glonassObs.Visibles = cell(KKMAX,0);
	elseif RINEX_TIPO == 'E'
		datosObs.GNSS = SistemaGNSS.Galileo;
		datosObs.galileoObs = cell2struct(cellgalileo,codigos,1);
		datosObs.galileoObs.Observables = mediciones;
		datosObs.galileoObs.Visibles = cell(KKMAX,0);
	elseif RINEX_TIPO == 'S'
		datosObs.GNSS = SistemaGNSS.SBAS;
		datosObs.sbasObs = cell2struct(cellgeo,codigos,1);
		datosObs.sbasObs.Observables = mediciones;
		datosObs.sbasObs.Visibles = cell(KKMAX,0);
	elseif RINEX_TIPO == 'M'
		datosObs.GNSS = [];		% Si es un archivo mixto los GNSS se llenan luego
		datosObs.gpsObs = cell2struct(cellgps,codigos,1);
		datosObs.glonassObs = cell2struct(cellglonass,codigos,1);
		datosObs.galileoObs = cell2struct(cellgalileo,codigos,1);
		datosObs.sbasObs = cell2struct(cellgeo,codigos,1);
		datosObs.gpsObs.Observables = mediciones;
		datosObs.glonassObs.Observables = mediciones;
		datosObs.galileoObs.Observables = mediciones;
		datosObs.sbasObs.Observables = mediciones;
		datosObs.gpsObs.Visibles = cell(KKMAX,0);
		datosObs.glonassObs.Visibles = cell(KKMAX,0);
		datosObs.galileoObs.Visibles = cell(KKMAX,0);
		datosObs.sbasObs.Visibles = cell(KKMAX,0);
	end
	
% En RINEX 3.01 se especifican explícitamente los GNSS presentes, cada uno con 
% sus observables
elseif RINEX_VER == 3
	
	% Convierto los códigos (chars) a mediciones (TipoMedicion)
	CC = length(codigos);
	for cc = 1:CC
		mediciones(cc,1) = TipoMedicion.(codigos{cc});
	end
	
	
	if ~isfield(datosObs,'GNSS')
		datosObs.GNSS = [];
	end
		
	if GNSS == 'G'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.GPS];
		datosObs.gpsObs = cell2struct(cellgps,codigos,1);
		datosObs.gpsObs.Observables = mediciones;
		datosObs.gpsObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'R'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.GLONASS];
		datosObs.glonassObs = cell2struct(cellglonass,codigos,1);
		datosObs.glonassObs.Observables = mediciones;
		datosObs.glonassObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'E'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.Galileo];
		datosObs.galileoObs = cell2struct(cellgalileo,codigos,1);
		datosObs.galileoObs.Observables = mediciones;
		datosObs.galileoObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'S'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.SBAS];
		datosObs.sbasObs = cell2struct(cellgeo,codigos,1);
		datosObs.sbasObs.Observables = mediciones;
		datosObs.sbasObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'J'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.QZSS];
		datosObs.qzssObs = cell2struct(cellqzss,codigos,1);
		datosObs.qzssObs.Observables = mediciones;
		datosObs.qzssObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'C'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.BeiDou];
		datosObs.bdsObs = cell2struct(cellbds,codigos,1);
		datosObs.bdsObs.Observables = mediciones;
		datosObs.bdsObs.Visibles = cell(KKMAX,0);
	elseif GNSS == 'I'
		datosObs.GNSS = [datosObs.GNSS; SistemaGNSS.IRNSS];
		datosObs.irnssObs = cell2struct(cellirnss,codigos,1);
		datosObs.irnssObs.Observables = mediciones;
		datosObs.irnssObs.Visibles = cell(KKMAX,0);
	end
	
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function [datosObs,KKMAX] = extenderMemoriaAsignada(datosObs)

KKEXT = 24*60*6;

KK = length(datosObs.tR);
KKMAX = KK+KKEXT;

datosObs.tR(KK+1:KKMAX) = NaN(KKEXT,1);
datosObs.Eventos(KK+1:KKMAX) = NaN(KKEXT,1);

if isfield(datosObs,'gpsObs')
	for nn = 1:length(datosObs.gpsObs.Observables)
		codigo_field = char(datosObs.gpsObs.Observables(nn));
		
		datosObs.gpsObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,32);
		datosObs.gpsObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,32);
		datosObs.gpsObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,32);
	end
	datosObs.gpsObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'glonassObs')
	for nn = 1:length(datosObs.glonassObs.Observables)
		codigo_field = char(datosObs.glonassObs.Observables(nn));
		
		datosObs.glonassObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,24);
		datosObs.glonassObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,24);
		datosObs.glonassObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,24);
	end
	datosObs.glonassObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'galileoObs')
	for nn = 1:length(datosObs.galileoObs.Observables)
		codigo_field = char(datosObs.galileoObs.Observables(nn));
		
		datosObs.galileoObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,40);
		datosObs.galileoObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,40);
		datosObs.galileoObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,40);
	end
	datosObs.galileoObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'bdsObs')
	for nn = 1:length(datosObs.bdsObs.Observables)
		codigo_field = char(datosObs.bdsObs.Observables(nn));
		
		datosObs.bdsObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,35);
		datosObs.bdsObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,35);
		datosObs.bdsObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,35);
	end
	datosObs.bdsObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'qzssObs')
	for nn = 1:length(datosObs.qzssObs.Observables)
		codigo_field = char(datosObs.qzssObs.Observables(nn));
		
		datosObs.qzssObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,7);
		datosObs.qzssObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,7);
		datosObs.qzssObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,7);
	end
	datosObs.qzssObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'irnssObs')
	for nn = 1:length(datosObs.irnssObs.Observables)
		codigo_field = char(datosObs.irnssObs.Observables(nn));
		
		datosObs.irnssObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,7);
		datosObs.irnssObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,7);
		datosObs.irnssObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,7);
	end
	datosObs.irnssObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end
if isfield(datosObs,'sbasObs')
	for nn = 1:length(datosObs.sbasObs.Observables)
		codigo_field = char(datosObs.sbasObs.Observables(nn));
		
		datosObs.sbasObs.(codigo_field).Valor(KK+1:KKMAX,:) = NaN(KKEXT,100);
		datosObs.sbasObs.(codigo_field).LLI(KK+1:KKMAX,:) = NaN(KKEXT,100);
		datosObs.sbasObs.(codigo_field).SSI(KK+1:KKMAX,:) = NaN(KKEXT,100);
	end
	datosObs.sbasObs.Visibles(KK+1:KKMAX,:) = cell(KKEXT,0);
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function datosObs = recortarMemoriaAsignada(datosObs,kk)

KK = length(datosObs.tR);

if kk == KK
	return;
end

datosObs.tR(kk+1:KK) = [];
datosObs.Eventos(kk+1:KK) = [];

if isfield(datosObs,'gpsObs')
	for nn = 1:length(datosObs.gpsObs.Observables)
		codigo_field = char(datosObs.gpsObs.Observables(nn));
		
		datosObs.gpsObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.gpsObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.gpsObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.gpsObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'glonassObs')
	for nn = 1:length(datosObs.glonassObs.Observables)
		codigo_field = char(datosObs.glonassObs.Observables(nn));
		
		datosObs.glonassObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.glonassObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.glonassObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.glonassObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'galileoObs')
	for nn = 1:length(datosObs.galileoObs.Observables)
		codigo_field = char(datosObs.galileoObs.Observables(nn));
		
		datosObs.galileoObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.galileoObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.galileoObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.galileoObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'bdsObs')
	for nn = 1:length(datosObs.bdsObs.Observables)
		codigo_field = char(datosObs.bdsObs.Observables(nn));
		
		datosObs.bdsObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.bdsObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.bdsObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.bdsObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'qzssObs')
	for nn = 1:length(datosObs.qzssObs.Observables)
		codigo_field = char(datosObs.qzssObs.Observables(nn));
		
		datosObs.qzssObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.qzssObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.qzssObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.qzssObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'irnssObs')
	for nn = 1:length(datosObs.irnssObs.Observables)
		codigo_field = char(datosObs.irnssObs.Observables(nn));
		
		datosObs.irnssObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.irnssObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.irnssObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.irnssObs.Visibles(kk+1:KK,:) = [];
end
if isfield(datosObs,'sbasObs')
	for nn = 1:length(datosObs.sbasObs.Observables)
		codigo_field = char(datosObs.sbasObs.Observables(nn));
		
		datosObs.sbasObs.(codigo_field).Valor(kk+1:KK,:) = [];
		datosObs.sbasObs.(codigo_field).LLI(kk+1:KK,:) = [];
		datosObs.sbasObs.(codigo_field).SSI(kk+1:KK,:) = [];
	end
	datosObs.sbasObs.Visibles(kk+1:KK,:) = [];
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function codigos = convertirCodigosRINEX2aRINEX3(codigos)

for nn = 1:length(codigos)
	
	cod_rinex2 = codigos{nn};
	cod_rinex3 = 'xxx';
	
	if cod_rinex2(1) == 'C' || cod_rinex2(1) == 'P'
		cod_rinex3(1) = 'C';
		cod_rinex3(2) = cod_rinex2(2);
	elseif cod_rinex2(1) == 'L'
		cod_rinex3(1) = 'L';
		cod_rinex3(2) = cod_rinex2(2);
	elseif cod_rinex2(1) == 'D'
		cod_rinex3(1) = 'D';
		cod_rinex3(2) = cod_rinex2(2);
	elseif cod_rinex2(1) == 'S'
		cod_rinex3(1) = 'S';
		cod_rinex3(2) = cod_rinex2(2);
	end
	
	if cod_rinex2(2) == '5' || cod_rinex2(2) == '6' || cod_rinex2(2) == '7' || cod_rinex2(2) == '8'
		cod_rinex3(3) = 'X';
	elseif cod_rinex2(2) == 'A'
		cod_rinex3(2) = '1';	% Soporte para observables de los RINEX 2.2
		cod_rinex3(3) = 'C';
	elseif cod_rinex2(1) ~= 'C'
		cod_rinex3(3) = 'P';
	else
		cod_rinex3(3) = 'C';
	end
	
	codigos{nn} = cod_rinex3;
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function GNSS = determinarSistemaGNSS(SYS)
	
if SYS == 'G' || SYS == ' '
	GNSS = SistemaGNSS.GPS;
	return;
elseif SYS == 'R'
	GNSS = SistemaGNSS.GLONASS;
	return;
elseif SYS == 'E'
	GNSS = SistemaGNSS.Galileo;
	return;
elseif SYS == 'C'
	GNSS = SistemaGNSS.BeiDou;
	return;
elseif SYS == 'J'
	GNSS = SistemaGNSS.QZSS;
	return;
elseif SYS == 'I'
	GNSS = SistemaGNSS.IRNSS;
	return;	
elseif SYS == 'S'
	GNSS = SistemaGNSS.SBAS;
	return;	
else
	GNSS = SistemaGNSS.UNKNOWN_GNSS;
	return;
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function stringGNSS = sistemaGNSS2stringEstructura(SYS)
	
if SYS == SistemaGNSS.GPS
	stringGNSS = 'gpsObs';
	return;
elseif SYS == SistemaGNSS.GLONASS
	stringGNSS = 'glonassObs';
	return;
elseif SYS == SistemaGNSS.Galileo
	stringGNSS = 'galileoObs';
	return;
elseif SYS == SistemaGNSS.BeiDou
	stringGNSS = 'bdsObs';
	return;
elseif SYS == SistemaGNSS.QZSS
	stringGNSS = 'qzssObs';
	return;
elseif SYS == SistemaGNSS.IRNSS
	stringGNSS = 'irnssObs';
	return;	
elseif SYS == SistemaGNSS.SBAS
	stringGNSS = 'sbasObs';
	return;	
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function datosObs = eliminarEstructurasSobrantesRINEX2(datosObs)

if ~ismember(SistemaGNSS.GPS,datosObs.GNSS)
	datosObs = rmfield(datosObs,'gpsObs');
end
if ~ismember(SistemaGNSS.GLONASS,datosObs.GNSS)
	datosObs = rmfield(datosObs,'glonassObs');
end
if ~ismember(SistemaGNSS.Galileo,datosObs.GNSS)
	datosObs = rmfield(datosObs,'galileoObs');
end
if ~ismember(SistemaGNSS.SBAS,datosObs.GNSS)
	datosObs = rmfield(datosObs,'sbasObs');
end

end
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
function datosObs = convertirFasesCiclosAMetros(datosObs)

NSIS = length(datosObs.GNSS);

for ss = 1:NSIS
	gnss_field = sistemaGNSS2stringEstructura(datosObs.GNSS(ss));
	
	NOBS = length(datosObs.(gnss_field).Observables);
	
	for nn = 1:NOBS
		
		tipoMed = datosObs.(gnss_field).Observables(nn);
		codigo = char(tipoMed);
		
		if tipoMedicion2claseMedicion(tipoMed) == ClaseMedicion.FASE_PORTADORA
			
			% Si estoy en GLONASS debo averiguar canal y l.d.o. uno por uno 
			if datosObs.GNSS(ss) == SistemaGNSS.GLONASS
				
				% Si no tengo información de canales GLONASS las dejo en ciclos
				if isfield(datosObs,'GlonassSlotFreq')					
					for jj = 1:24
						indx = find(datosObs.GlonassSlotFreq(:,1) == jj);
						if isempty(indx)
							continue;
						else
							channel = datosObs.GlonassSlotFreq(indx,2);
						end
						lambda = obtenerLongitudDeOnda(SistemaGNSS.GLONASS,tipoMed,channel);
						
						datosObs.(gnss_field).(codigo).Valor(:,jj) = lambda.*datosObs.(gnss_field).(codigo).Valor(:,jj);
					end					
				end
			else
				lambda = obtenerLongitudDeOnda(datosObs.GNSS(ss),tipoMed,[]);
				
				datosObs.(gnss_field).(codigo).Valor = lambda.*datosObs.(gnss_field).(codigo).Valor;
			end
			
		end
	end

end

end
%-------------------------------------------------------------------------------




