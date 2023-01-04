function pcvCorr = correccionVariacionCentroFaseAntenaSateliteGps(t,r,rj,PRN,tipoMed,datosAPC)
%CORRECCIONVARIACIONCENTROFASEANTENASATELITEGPS Corrección por variaciones del 
%offset del centro de fase de antena de satélite GPS
% Dado un tiemo GPS, la posición de un satélite, la posición de receptor y los
% datos obtenidos de un archivo ANTEX calcula la corrección por varicaciones 
% del offset del centro de fase de la antena del satélite. Actualmente solo se
% implementan variaciones dependientes del ángulo nadir, y no las dependientes
% del azimut (suele ser lo único necesario para satélites GPS).
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición [s]
%	r (3x1)		- Posición ECEF a-priori del receptor
%	rj (3x1)	- Posición ECEF del satélite
%	PRN			- PRN del satélite del que se desea calcular su posición
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la función leerArchivoANTEX
%
% DEVOLUCIÓN:		
%	pcvCorr		- Corrección por variaciones del offset del centro de fase 
%				de antena de satélite para el modelo de mediciones

global IFC_A1 IFC_A2


% Busco la estructura que corresponde al satélite
NATX = length(datosAPC);

% Recorro todos los datos del ANTEX
for nn = 1:NATX
	% Busco aquellos que son del GNSS y del satélite deseado
	if (datosAPC(nn).PRN) == PRN && (uint32(datosAPC(nn).GNSS) == uint32(SistemaGNSS.GPS))
		
		tI = datosAPC(nn).tValidFrom;
		tF = datosAPC(nn).tValidUntil;
		
		% Busco que sea de una época posterior a la entrada en servicio
		if (t > tI) && ((t < tF) || isnan(tF))
			antexSat = datosAPC(nn);
			break;
		end
		
	end		
end


% Determino el ángulo respecto al nadir del satélite (gamma [º])
rr = norm(r);
rrj = norm(rj);
gamma = asind(sin(acos(dot(r,rj)/(rr*rrj)))*rr/norm(rj-r));


% Si el ángulo del nadir está fuera del límite calibrado no hay PCV
if gamma > antexSat.ZEN2
	pcvCorr = 0;
	return;
end


% Busco la calibración más cercana redondeando hacia 0 (sumo 1 por la indexación)
zen_indx = 1 + floor(((gamma - antexSat.ZEN1)/antexSat.DZEN));

		
% Busco las frecuencias que corresponden al tipo de medición
frec_indx = tipoMedicion2bandaFrecuencia(tipoMed);

% Busco el offset que corresponde a la/s frecuencias en cuestión y armo la
% combinación que corresponda en cada caso
if length(frec_indx) == 1
	
	% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
	if (zen_indx == antexSat.NZEN) || (zen_indx == 1)
		pcvCorr = squeeze(antexSat.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx));
	else
		diff = ((gamma - antexSat.ZEN1)/antexSat.DZEN) - (zen_indx - 1);
		
		pcvCorr = squeeze(antexSat.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx))*(1 - diff) + squeeze(antexSat.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx+1))*diff;
	end
	
% Combinaciónes libres de ionósfera	
elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
	
	% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
	if (zen_indx == antexSat.NZEN) || (zen_indx == 1)
		
		pcvCorr1 = squeeze(antexSat.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx));
		pcvCorr2 = squeeze(antexSat.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx));
		
		pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
		
	else
		diff = ((gamma - antexSat.ZEN1)/antexSat.DZEN) - (zen_indx - 1);
		
		pcvCorr1 = squeeze(antexSat.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx))*(1 - diff) + squeeze(antexSat.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx+1))*diff;
		pcvCorr2 = squeeze(antexSat.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx))*(1 - diff) + squeeze(antexSat.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx+1))*diff;
		
		pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
	end
	
end

end

