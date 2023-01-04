function drAPC = obtenerCentroFaseAntenaSateliteGps(t,PRN,tipoMed,datosAPC)
%OBTENERCENTROFASEANTENASATELITEGPS Obtiene el vector offset APC en el marco de
%referencia del sat�lite
% 
% ARGUMENTOS:
%	t			- Tiempo GPS de la �poca en la que se desea el vector [s]
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	tipoMed		- Tipo de medici�n a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosAPC	- Estructura de datos provista por la funci�n 
%				leerArchivoANTEX.
% 
% DEVOLUCI�N:
%	drAPC (3x1)	- Vector offset del centro de fase de la antena de sat�lite en
%				el marco de referencia del sat�lite

global IFC_A1 IFC_A2


NATX = length(datosAPC);

% Recorro todos los datos del ANTEX
for nn = 1:NATX

	% Busco aquellos que son del GNSS y del sat�lite deseado
	if  (datosAPC(nn).PRN) == PRN && (uint32(datosAPC(nn).GNSS) == uint32(SistemaGNSS.GPS))
		
		tI = datosAPC(nn).tValidFrom;
		tF = datosAPC(nn).tValidUntil;
		
		% Busco que sea de una �poca posterior a la entrada en servicio
		if (t > tI) && ((t < tF) || isnan(tF))
			offsetsAPC = datosAPC(nn).APC;
			break;
		end
		
	end
		
end

% Busco las frecuencias que corresponden al tipo de medici�n
frec_indx = tipoMedicion2bandaFrecuencia(tipoMed);

% Busco el offset que corresponde a la/s frecuencias en cuesti�n y armo la
% combinaci�n que corresponda en cada caso
if length(frec_indx) == 1
	
	drAPC = squeeze(offsetsAPC(frec_indx,SistemaGNSS.GPS,:));
	
% Combinaci�nes libres de ion�sfera	
elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
	
	% Los archivos ANTEX especifican los offsets de L1 y L2 directamente para
	% las combinaciones libres de ion�sfera, as� que no hace falta combinar
	
	drAPC1 = squeeze(offsetsAPC(frec_indx(1),SistemaGNSS.GPS,:));
	drAPC2 = squeeze(offsetsAPC(frec_indx(2),SistemaGNSS.GPS,:));
	
	drAPC = IFC_A1*drAPC1 + IFC_A2*drAPC2;
	
end

end

