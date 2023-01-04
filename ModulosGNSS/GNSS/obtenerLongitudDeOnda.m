function lambda = obtenerLongitudDeOnda(gnss,tipoMed,channel)
%OBTENERLONGITUDDEONDA Obtiene la longtud de onda en función del GNSS y medición
% Devuelve la longitud de onda correspondiente al sistema GNSS y al tipo de
% medición que se especifiquen. Sirve también para combinaciónes de mediciones.
% 
% ARGUMENTOS:
%	gnss	- Sistema GNSS utilizado(clase SistemaGNSS)
%	tipoMed - Medición utilizada (clase TipoMedicion)
%	channel	- Número de canal (necesario solo para GLONASS)
% 
% DEVOLUCIÓN:
%	lambda	- Longitud de onda del observable especificado [m]


global LUZ LAMBDA_IF LAMBDA_NL LAMBDA_WL ...
	LAMBDA_GF LAMBDA_G1 LAMBDA_G2 ...
	LAMBDA_GPS_L1 LAMBDA_GPS_L2 LAMBDA_GPS_L5 ...
	LAMBDA_Galileo_E1 LAMBDA_Galileo_E5 LAMBDA_Galileo_E5a LAMBDA_Galileo_E5b LAMBDA_Galileo_E6 ...
	LAMBDA_BDS_B1 LAMBDA_BDS_B2 LAMBDA_BDS_B3 ...
	LAMBDA_QZSS_L1 LAMBDA_QZSS_L2 LAMBDA_QZSS_L5 LAMBDA_QZSS_E6 ...
	LAMBDA_IRNSS_L5 LAMBDA_IRNSS_S

codigo = char(tipoMed);

if gnss == SistemaGNSS.GPS || gnss == SistemaGNSS.SBAS
	if codigo(2) == '1'
		lambda = LAMBDA_GPS_L1;
	elseif codigo(2) == '2'
		lambda = LAMBDA_GPS_L2;
	elseif codigo(2) == '5'
		lambda = LAMBDA_GPS_L5;
	elseif strcmp(codigo,'PIF') || strcmp(codigo,'LIF') || strcmp(codigo,'PCIF')
		lambda = LAMBDA_IF;
	elseif strcmp(codigo(2:3),'NL')
		lambda = LAMBDA_NL;
	elseif strcmp(codigo(2:3),'WL') || strcmp(codigo,'MWC')
		lambda = LAMBDA_WL;
	elseif strcmp(codigo(2:3),'GF')
		lambda = LAMBDA_GF;
	elseif strcmp(codigo(1:2),'G1')
		lambda = LAMBDA_G1;
	elseif strcmp(codigo(1:2),'G2')
		lambda = LAMBDA_G2;	
	else
		lambda = NaN;
	end
elseif gnss == SistemaGNSS.GLONASS
	if codigo(2) == '1' || codigo(2) == '2'
		lambda = LUZ / obtenerFrecuencia(gnss,tipoMed,channel);
	else
		lambda = NaN;
	end
elseif gnss == SistemaGNSS.Galileo
	if codigo(2) == '1'
		lambda = LAMBDA_Galileo_E1;
	elseif codigo(2) == '5'
		lambda = LAMBDA_Galileo_E5a;
	elseif codigo(2) == '6'
		lambda = LAMBDA_Galileo_E6;
	elseif codigo(2) == '7'
		lambda = LAMBDA_Galileo_E5b;
	elseif codigo(2) == '8'
		lambda = LAMBDA_Galileo_E5;
	else
		lambda = NaN;
	end
elseif gnss == SistemaGNSS.BeiDou
	if codigo(2) == '2'
		lambda = LAMBDA_BDS_B1;
	elseif codigo(2) == '6'
		lambda = LAMBDA_BDS_B3;
	elseif codigo(2) == '7'
		lambda = LAMBDA_BDS_B2;
	else
		lambda = NaN;
	end
elseif gnss == SistemaGNSS.QZSS
	if codigo(2) == '1'
		lambda = LAMBDA_QZSS_L1;
	elseif codigo(2) == '2'
		lambda = LAMBDA_QZSS_L2;
	elseif codigo(2) == '5'
		lambda = LAMBDA_QZSS_L5;
	elseif codigo(2) == '6'
		lambda = LAMBDA_QZSS_E6;
	else
		lambda = NaN;
	end
elseif gnss == SistemaGNSS.IRNSS
	if codigo(2) == '5'
		lambda = LAMBDA_IRNSS_L5;
	elseif codigo(2) == '9'
		lambda = LAMBDA_IRNSS_S;
	else
		lambda = NaN;
	end
end


end
%-------------------------------------------------------------------------------