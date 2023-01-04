%% Constantes GNSS
clear;

global SECONDS_IN_WEEK SECONDS_IN_DAY SECONDS_IN_HOUR SECONDS_IN_MINUTE ...
	WE LUZ ...
	FREQ_GPS_L1 FREQ_GPS_L2 FREQ_GPS_L5 ...
	FREQ_GLONASS_L1 FREQ_GLONASS_L2 FREQ_GLONASS_L3 FREQ_GLONASS_L1_CHANNELDIV FREQ_GLONASS_L2_CHANNELDIV...
	FREQ_BDS_B1 FREQ_BDS_B2 FREQ_BDS_B3 ...
	FREQ_Galileo_E1 FREQ_Galileo_E5 FREQ_Galileo_E5a FREQ_Galileo_E5b FREQ_Galileo_E6 ...
	FREQ_QZSS_L1 FREQ_QZSS_L2 FREQ_QZSS_L5 FREQ_QZSS_E6 ...
	FREQ_IRNSS_L5 FREQ_IRNSS_S ...
	FREQ_GPS_CACODE FREQ_GPS_PCODE FREQ_GPS_L2CMCODE FREQ_GPS_L2CLCODE...
	FREQ_GLONASS_CACODE FREQ_GLONASS_PCODE ...
	LAMBDA_GPS_L1 LAMBDA_GPS_L2 LAMBDA_GPS_L5 ...
	LAMBDA_GLONASS_L1 LAMBDA_GLONASS_L2 LAMBDA_GLONASS_L3 ...
	LAMBDA_BDS_B1 LAMBDA_BDS_B2 LAMBDA_BDS_B3 ...
	LAMBDA_Galileo_E1 LAMBDA_Galileo_E5 LAMBDA_Galileo_E5a LAMBDA_Galileo_E5b LAMBDA_Galileo_E6 ...
	LAMBDA_QZSS_L1 LAMBDA_QZSS_L2 LAMBDA_QZSS_L5 LAMBDA_QZSS_E6 ...
	LAMBDA_IRNSS_L5 LAMBDA_IRNSS_S ...
	IFC_A1 IFC_A2 ...
	NLC_A1 NLC_A2 ...
	WLC_A1 WLC_A2 ...
	MPC1_A1 MPC1_A2 ...
	MPC2_A1 MPC2_A2 ...
	LAMBDA_IF LAMBDA_NL LAMBDA_WL ...
	LAMBDA_GF LAMBDA_G1 LAMBDA_G2

%-------------------------------------------------------------------------------
% Constantes generales
SECONDS_IN_WEEK		= 604800;
SECONDS_IN_DAY		= 86400;
SECONDS_IN_HOUR		= 3600;
SECONDS_IN_MINUTE	= 60;

% Velocidad angular de rotación terrestre [rad/s] (WGS-84)
WE		= 7.2921151467e-5;

% Velocidad de la luz [m/s]
LUZ		= 2.99792458E8;
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Frecuencias de las bandas L1, L2 y L5 de GPS [Hz]
FREQ_GPS_L1 = 1575.42e6;
FREQ_GPS_L2 = 1227.6e6;
FREQ_GPS_L5 = 1176.45e6;

% Frecuencias de las bandas L1, L2 y L3 de GLONASS [Hz]
FREQ_GLONASS_L1 = 1602.0e6;
FREQ_GLONASS_L2 = 1246.0e6;
FREQ_GLONASS_L3 = 1202.025e6;
FREQ_GLONASS_L1_CHANNELDIV = 562.5e3;
FREQ_GLONASS_L2_CHANNELDIV = 437.5e3;

% Frecuencias de las bandas B1, B2 y B3 de BeiDou [Hz]
FREQ_BDS_B1 = 1561.098e6;
FREQ_BDS_B2 = 1207.14e6;
FREQ_BDS_B3 = 1268.52e6;

% Frecuencias de las bandas E1, E5, E5a, E5b y E6 de Galileo [Hz]
FREQ_Galileo_E1 = 1572.42e6;
FREQ_Galileo_E5 = 1191.795e6;
FREQ_Galileo_E5a = 1176.45e6;
FREQ_Galileo_E5b = 1207.14e6;
FREQ_Galileo_E6 = 1278.75e6;

% Frecuencias de las bandas L1, L2, L5 y E6 de QZSS [Hz]
FREQ_QZSS_L1 = 1572.42e6;
FREQ_QZSS_L2 = 1227.6e6;
FREQ_QZSS_L5 = 1176.45e6;
FREQ_QZSS_E6 = 1278.75e6;

% Frecuencias de las bandas L5 y S de IRNSS [Hz]
FREQ_IRNSS_L5 = 1176.45e6;
FREQ_IRNSS_S = 2492.028e6;
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Frecuencia de las secuencias de códigos de GPS [bps]
FREQ_GPS_CACODE = 1.023e6;
FREQ_GPS_PCODE = 10.023e6;
FREQ_GPS_L2CMCODE = 511.5e3;
FREQ_GPS_L2CLCODE = 511.5e3;
FREQ_GLONASS_CACODE = 0.511e6;
FREQ_GLONASS_PCODE = 5.11e6;
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Longitudes de onda de las bandas L1, L2 y L5 de GPS [m]
LAMBDA_GPS_L1 = LUZ/FREQ_GPS_L1;
LAMBDA_GPS_L2 = LUZ/FREQ_GPS_L2;
LAMBDA_GPS_L5 = LUZ/FREQ_GPS_L5;

% Longitudes de onda de las bandas L1, L2 y L3 de GLONASS [m]
LAMBDA_GLONASS_L1 = LUZ/FREQ_GLONASS_L1;
LAMBDA_GLONASS_L2 = LUZ/FREQ_GLONASS_L2;
LAMBDA_GLONASS_L3 = LUZ/FREQ_GLONASS_L3;

% Longitudes de onda de las bandas L1, L2 y L3 de GLONASS [m]
LAMBDA_BDS_B1 = LUZ/FREQ_BDS_B1;
LAMBDA_BDS_B2 = LUZ/FREQ_BDS_B2;
LAMBDA_BDS_B3 = LUZ/FREQ_BDS_B3;

% Longitudes de onda de las bandas E1, E5a, E5b y E6 de Galileo [m]
LAMBDA_Galileo_E1 = LUZ/FREQ_Galileo_E1;
LAMBDA_Galileo_E5 = LUZ/FREQ_Galileo_E5;
LAMBDA_Galileo_E5a = LUZ/FREQ_Galileo_E5a;
LAMBDA_Galileo_E5b = LUZ/FREQ_Galileo_E5b;
LAMBDA_Galileo_E6 = LUZ/FREQ_Galileo_E6;

% Longitudes de onda de las bandas L1, L2, L5 y E6 de QZSS [m]
LAMBDA_QZSS_L1 = LUZ/FREQ_QZSS_L1;
LAMBDA_QZSS_L2 = LUZ/FREQ_QZSS_L2;
LAMBDA_QZSS_L5 = LUZ/FREQ_QZSS_L5;
LAMBDA_QZSS_E6 = LUZ/FREQ_QZSS_E6;

% Longitudes de onda de las bandas L5 y S de IRNSS [m]
LAMBDA_IRNSS_L5 = LUZ/FREQ_IRNSS_L5;
LAMBDA_IRNSS_S = LUZ/FREQ_IRNSS_S;
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Constantes para la combinación libre de ionósfera GPS L1-L2 [-]
IFC_A1 = FREQ_GPS_L1^2/(FREQ_GPS_L1^2 - FREQ_GPS_L2^2);
IFC_A2 = FREQ_GPS_L2^2/(FREQ_GPS_L2^2 - FREQ_GPS_L1^2);

% Constantes para la combinación narrow-lane GPS L1-L2 [-]
NLC_A1 = FREQ_GPS_L1/(FREQ_GPS_L1 + FREQ_GPS_L2);
NLC_A2 = FREQ_GPS_L2/(FREQ_GPS_L2 + FREQ_GPS_L1);

% Constantes para la combinación wide-lane GPS L1-L2 [-]
WLC_A1 = FREQ_GPS_L1/(FREQ_GPS_L1 - FREQ_GPS_L2);
WLC_A2 = FREQ_GPS_L2/(FREQ_GPS_L2 - FREQ_GPS_L1);

% Constantes para la combinación de multicamino GPS L1 [-]
MPC1_A1 = - (FREQ_GPS_L1^2 + FREQ_GPS_L2^2)/(FREQ_GPS_L1^2 - FREQ_GPS_L2^2);
MPC1_A2 = (2*FREQ_GPS_L2^2)/(FREQ_GPS_L1^2 - FREQ_GPS_L2^2);

% Constantes para la combinación de multicamino GPS L2 [-]
MPC2_A1 = - (2*FREQ_GPS_L1^2)/(FREQ_GPS_L1^2 - FREQ_GPS_L2^2);
MPC2_A2 = (FREQ_GPS_L1^2 + FREQ_GPS_L2^2)/(FREQ_GPS_L1^2 - FREQ_GPS_L2^2);
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Longitud de onda de la señal resultante de la combinación IF [m]
LAMBDA_IF = IFC_A1*LAMBDA_GPS_L1 + IFC_A2*LAMBDA_GPS_L2;

% Longitud de onda de la señal resultante de la combinación narrow-lane GPS L1-L2 [m]
LAMBDA_NL = LUZ/(FREQ_GPS_L1 + FREQ_GPS_L2);

% Longitud de onda de la señal resultante de la combinación wide-lane GPS L1-L2 [m]
LAMBDA_WL = LUZ/(FREQ_GPS_L1 - FREQ_GPS_L2);

% Longitud de onda de la señal resultante de la combinación libre de geometría GPS L1-L2 [m]
LAMBDA_GF = LAMBDA_GPS_L1 - LAMBDA_GPS_L2;

% Longitud de onda de la señal resultante de la combinación GRAPHIC GPS L1 [m]
LAMBDA_G1 = LAMBDA_GPS_L1/2;

% Longitud de onda de la señal resultante de la combinación GRAPHIC GPS L2 [m]
LAMBDA_G2 = LAMBDA_GPS_L2/2;
%-------------------------------------------------------------------------------


save('../Datos/ConstantesGNSS.mat');

