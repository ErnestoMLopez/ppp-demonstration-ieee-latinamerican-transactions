function drAPC = obtenerCentroFaseAntenaReceptorGps(antena,domo,tipoMed,datosATX)
%OBTENERCENTROFASEANTENARECEPTORGPS Obtiene el vector offset APC en el marco de
%referencia local ENU del receptor
% 
% ARGUMENTOS:
%	antena		- Nombre de la antena de receptor. String de hasta 15 char
%	domo		- Nombre del domo de receptor. String de hasta 4 char
%	tipoMed		- Tipo de medición a usar (clase TipoMedicion), para
%				determinar la frecuencia en la que se desea el APC.
%	datosATX	- Estructura de datos provista por la función 
%				leerArchivoANTEX.
% 
% DEVOLUCIÓN:
%	drAPC (3x1)	- Vector offset del centro de fase de la antena de satélite en
%				el marco de referencia local ENU del receptor

global IFC_A1 IFC_A2


NATX = length(datosATX);

% Busco las frecuencias que corresponden al tipo de medición
frec_indx = tipoMedicion2bandaFrecuencia(tipoMed);

% Si se pasa una sola estructura ANTEX se asume que es la correcta para la
% antena y el domo en cuestión
if NATX == 1
	
	flag_antena = strcmp(antena,datosATX.Antena);
	
	if ~flag_antena
		error('La antena no se corresponde a los datos ANTEX disponibles');
	end
		
	if length(frec_indx) == 1
		
		drAPC = squeeze(datosATX.APC(frec_indx,SistemaGNSS.GPS,:));
		
	% Combinaciónes libres de ionósfera
	elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
		
		drAPC1 = squeeze(datosATX.APC(frec_indx(1),SistemaGNSS.GPS,:));
		drAPC2 = squeeze(datosATX.APC(frec_indx(2),SistemaGNSS.GPS,:));
		
		drAPC = IFC_A1*drAPC1 + IFC_A2*drAPC2;
		
	end
	
	% Los datos del archivo ANTEX usan coordenadas NEU, reordeno a ENU
	drAPC = [drAPC(2); drAPC(1); drAPC(3)];
	
	return;
end


% Si están todos los datos del ANTEX los recorro buscando el correcto
for nn = 1:NATX

	flag_antena = strcmp(antena,datosATX(nn).Antena);
	flag_domo = strcmp(domo,datosATX(nn).Domo);
	
	if flag_antena && flag_domo
		
		if length(frec_indx) == 1
			
			drAPC = squeeze(datosATX(nn).APC(frec_indx,SistemaGNSS.GPS,:));
			
			% Combinaciónes libres de ionósfera
		elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
			
			drAPC1 = squeeze(datosATX(nn).APC(frec_indx(1),SistemaGNSS.GPS,:));
			drAPC2 = squeeze(datosATX(nn).APC(frec_indx(2),SistemaGNSS.GPS,:));
			
			drAPC = IFC_A1*drAPC1 + IFC_A2*drAPC2;
			
		end
		
		break;
		
	end
	
end

% Los datos del archivo ANTEX usan coordenadas NEU, reordeno a ENU
drAPC = [drAPC(2); drAPC(1); drAPC(3)];

end

