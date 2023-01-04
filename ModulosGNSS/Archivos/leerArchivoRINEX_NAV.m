function [datosNav] = leerArchivoRINEX_NAV(archivonav)
%LEERARCHIVORINEX_NAV Lee un archivo RINEX (formato 2.11) de navegación
% 
% ARGUMENTOS:
%	archivonav	- Nombre del archivo a leer
% 
% DEVOLUCIÓN:
%	datosNav	- Estructura con los datos leídos


% Abro el archivo
if (exist(archivonav,'file') == 2)
    fid = fopen(archivonav,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivonav), 'ERROR!');
end


% Leo el encabezado
[datosNav,RINEX_VER] = leerEncabezadoRINEX_NAV(fid);


datosEph = [];

% Voy recorriendo cada efemérides
while ~feof(fid)
	
	if RINEX_VER == 2
		datosEphAct = leerEfemeridesGpsRINEX_NAV2(fid);
	elseif RINEX_VER == 3
		datosEphAct = leerEfemeridesGpsRINEX_NAV3(fid);
	end
	
	% Concateno las efemérides
	datosEph = [datosEph; datosEphAct];

end

datosNav.gpsEph = datosEph;

fclose(fid);

end



%-------------------------------------------------------------------------------
function [datosNav,RINEX_VER] = leerEncabezadoRINEX_NAV(fid)

tline = fgetl(fid);

while isempty(strfind(tline,'END OF HEADER'))
	
	if ~isempty(strfind(tline,'RINEX VERSION / TYPE'))
		datosNav.Version = str2double(tline(1:9));
		RINEX_VER = fix(datosNav.Version);
		RINEX_TIPO = tline(21);
		
		if RINEX_VER ~= 2
			error('El archivo RINEX_NAV es de una versión no soportada aún');
		end
		if RINEX_TIPO ~= 'N'
			error('El archivo RINEX_NAV es de un GNSS no soportado aún');
		else
			datosNav.Producto = 'RINEX_NAV';
		end

		
	elseif ~isempty(strfind(tline,'ION ALPHA'))
		
		aux = textscan(tline(1:60),'%f');
		datosNav.IonoAlpha = aux{1};
		

	elseif ~isempty(strfind(tline,'ION BETA'))
		
		aux = textscan(tline(1:60),'%f');
		datosNav.IonoBeta = aux{1};
		
		
	elseif ~isempty(strfind(tline,'DELTA-UTC: A0,A1,T,W'))
		
		aux = textscan(tline(1:41),'%f');
		aux2 = aux{1};
		
		datosNav.DeltaUTC.A0 = aux2(1);
		datosNav.DeltaUTC.A1 = aux2(2);
		datosNav.DeltaUTC.T = str2double(tline(42:50));
		datosNav.DeltaUTC.W = str2double(tline(51:59));
		
		
	elseif ~isempty(strfind(tline,'LEAP SECONDS'))
		
		datosNav.LeapSeconds = str2double(tline(1:7));
		
	end

	tline = fgetl(fid);
	
end

end
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
function datosEph = leerEfemeridesGpsRINEX_NAV2(fid)

SECONDS_IN_WEEK = 7*24*60*60;

datosEph = generarEstructuraEfemerides(SistemaGNSS.GPS);

tline = fgetl(fid);
while ~isempty(strfind(tline,'COMMENT'))
	tline = fgetl(fid);
end

% Si ya no quedaban más efemérides salgo
if feof(fid)
	return;
end

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 1
%----------------------------------------------------------------------
YYYY = 2000 + str2double(tline(4:5));
MM = str2double(tline(7:8));
DD = str2double(tline(10:11));
hh = str2double(tline(13:14));
mm = str2double(tline(16:17));
ss = str2double(tline(18:22));
aux = textscan(tline(23:79),'%f');
linea = aux{1};

PRN	= str2double(tline(1:2));				% PRN
toc	= ymdhms2gpsTime(YYYY,MM,DD,hh,mm,ss);	% Time of clock
af0	= linea(1);								% Clock bias  (s)
af1	= linea(2);								% Clock drift (s/s)
af2	= linea(3);								% Clock drift rate (s/s/s)

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 2
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

IODE	= linea(1);		% Issue of Data (Ephemeris)
Crs		= linea(2);		% Amplitude of the Sine Harmonic Correction, term to the orbit radius
Delta_n	= linea(3);		% Mean Motion Difference from Computed Value, rad/s
M0		= linea(4);		% Mean Anomaly at Reference Time, rad

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 3
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

Cuc		= linea(1);		% Amplitude of the Cosine Harmonic Correction, term to the Argument of Latitude
e		= linea(2);		% Eccentricity
Cus		= linea(3);		% Amplitude of the Sine Harmonic Correction, term to the Argument of Latitude
sqrt_a	= linea(4);		% Square root of the semi-major Axis, m^0.5

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 4
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

toe		= linea(1);		% Time of Ephemeris (sec into GPS week)
Cic		= linea(2);		% Amplitude of the Cosine Harmonic Correction, term to the Angle of Inclination
OMEGA0	= linea(3);		% Longitude of Ascending Node of Orbit Plane at Weekly Epoch, rad
Cis		= linea(4);		% Amplitude of the Sine Harmonic Correction, term to the Angle of Inclination

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 5
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

i0			= linea(1);		% Inclination Angle at Reference Time, rad
Crc			= linea(2);		% Amplitude of the Cosine Harmonic Correction, term to the Orbit Radius
omega		= linea(3);		% Argument of Perigee, rad
OMEGA_DOT	= linea(4);		% Rate of Change of Right Ascension, rad/s

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 6
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

i_DOT			= linea(1);		% Rate of change of inclination angle, rad/s
L2_Codes		= linea(2);		% Codes on L2 channel (unecessary)
GPS_WEEK		= linea(3);		% GPS Week Number (to go with Toe)
L2_PDataFlag	= linea(4);		% L2 flag

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 7
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

Accuracy	= linea(1);		% Satellite accuracy
Health		= linea(2);		% Satellite health (0 = usable)
TGD			= linea(3);		% Group delay time
IODC		= linea(4);		% Issue of Data Clock

%----------------------------------------------------------------------
% PARAMETROS DE LA LINEA 8
%----------------------------------------------------------------------
tline = fgetl(fid);

aux = textscan(tline,'%f');
linea = aux{1};

ttom			= linea(1);		% Transmission time of message
FitInterval		= linea(2);		% Fit interval [h]

%----------------------------------------------------------------------
% Cargo todos los parámetros en la estructura, con todos los tiempos de referencia
% ya en formato tiempo GPS [s] y el fit interval corregido para los casos en que
% figura como 0 (valor que según el ICD corresponde a 4 horas
%----------------------------------------------------------------------

datosEph.PRN			= PRN;
datosEph.toc			= toc;
datosEph.af0			= af0;
datosEph.af1			= af1;
datosEph.af2			= af2;

datosEph.IODE			= IODE;
datosEph.Crs			= Crs; 
datosEph.Delta_n		= Delta_n;
datosEph.M0				= M0;

datosEph.Cuc			= Cuc;
datosEph.e				= e;
datosEph.Cus			= Cus;
datosEph.sqrt_a			= sqrt_a;

datosEph.toe			= GPS_WEEK*SECONDS_IN_WEEK + toe;
datosEph.Cic			= Cic;
datosEph.OMEGA0			= OMEGA0;
datosEph.Cis			= Cis;

datosEph.i0				= i0;
datosEph.Crc			= Crc;
datosEph.omega			= omega;
datosEph.OMEGA_DOT		= OMEGA_DOT;

datosEph.i_DOT			= i_DOT;
datosEph.L2_Codes		= L2_Codes;
datosEph.GPS_WEEK		= GPS_WEEK;
datosEph.L2_PDataFlag	= L2_PDataFlag;

datosEph.Accuracy		= Accuracy;
datosEph.Health			= Health;
datosEph.TGD			= TGD;
datosEph.IODC			= IODC;

datosEph.ttom			= GPS_WEEK*SECONDS_IN_WEEK + ttom;
if FitInterval == 0
	datosEph.FitInterval = 4;
else
	datosEph.FitInterval = FitInterval;
end

end
%-------------------------------------------------------------------------------