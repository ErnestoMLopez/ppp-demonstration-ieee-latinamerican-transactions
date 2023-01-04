function frec = obtenerFrecuencia(gnss,tipoMed,channel)
%OBTENERFRECUENCIA Obtiene la frecuencia en función del GNSS y medición
% Devuelve la frecuencia correspondiente al sistema GNSS y al tipo de
% medición que se especifiquen.
% 
% ARGUMENTOS:
%	gnss	- Sistema GNSS utilizado(clase SistemaGNSS)
%	tipoMed - Medición utilizada (clase TipoMedicion)
%	channel - Número de canal (necesario solo para GLONASS)
% 
% DEVOLUCIÓN:
%	frec	- Frecuencia del observable especificado [Hz]
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 14/01/2020

global FREQ_GPS_L1 FREQ_GPS_L2 FREQ_GPS_L5 ...
	FREQ_GLONASS_L1 FREQ_GLONASS_L2 FREQ_GLONASS_L3 FREQ_GLONASS_L1_CHANNELDIV FREQ_GLONASS_L2_CHANNELDIV...
	FREQ_BDS_B1 FREQ_BDS_B2 FREQ_BDS_B3 ...
	FREQ_Galileo_E1 FREQ_Galileo_E5 FREQ_Galileo_E5a FREQ_Galileo_E5b FREQ_Galileo_E6 ...
	FREQ_QZSS_L1 FREQ_QZSS_L2 FREQ_QZSS_L5 FREQ_QZSS_E6 ...
	FREQ_IRNSS_L5 FREQ_IRNSS_S

codigo = char(tipoMed);

if gnss == SistemaGNSS.GPS || gnss == SistemaGNSS.SBAS
	if codigo(2) == '1'
		frec = FREQ_GPS_L1;
	elseif codigo(2) == '2'
		frec = FREQ_GPS_L2;
	elseif codigo(2) == '5'
		frec = FREQ_GPS_L5;	
	end
elseif gnss == SistemaGNSS.GLONASS
	if codigo(2) == '1'
		frec = FREQ_GLONASS_L1 + channel*FREQ_GLONASS_L1_CHANNELDIV;
	elseif codigo(2) == '2'
		frec = FREQ_GLONASS_L2 + channel*FREQ_GLONASS_L2_CHANNELDIV;
	elseif codigo(2) == '3'
		frec = FREQ_GLONASS_L3;
	end
elseif gnss == SistemaGNSS.Galileo
	if codigo(2) == '1'
		frec = FREQ_Galileo_E1;
	elseif codigo(2) == '5'
		frec = FREQ_Galileo_E5a;
	elseif codigo(2) == '6'
		frec = FREQ_Galileo_E6;
	elseif codigo(2) == '7'
		frec = FREQ_Galileo_E5b;
	elseif codigo(2) == '8'
		frec = FREQ_Galileo_E5;
	end
elseif gnss == SistemaGNSS.BeiDou
	if codigo(2) == '2'
		frec = FREQ_BDS_B1;
	elseif codigo(2) == '6'
		frec = FREQ_BDS_B3;
	elseif codigo(2) == '7'
		frec = FREQ_BDS_B2;
	end
elseif gnss == SistemaGNSS.QZSS
	if codigo(2) == '1'
		frec = FREQ_QZSS_L1;
	elseif codigo(2) == '2'
		frec = FREQ_QZSS_L2;
	elseif codigo(2) == '5'
		frec = FREQ_QZSS_L5;
	elseif codigo(2) == '6'
		frec = FREQ_QZSS_E6;
	end
elseif gnss == SistemaGNSS.IRNSS
	if codigo(2) == '5'
		frec = FREQ_IRNSS_L5;
	elseif codigo(2) == '9'
		frec = FREQ_IRNSS_S;
	end
end


end
%-------------------------------------------------------------------------------