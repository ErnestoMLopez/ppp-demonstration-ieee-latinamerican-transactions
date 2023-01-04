function pcvCorr = correccionVariacionCentroFaseAntenaReceptorGps(r,rj,O_B2F,antena,domo,tipoMed,datosATX)
%CORRECCIONVARIACIONCENTROFASEANTENARECEPTORGPS Correcci�n por variaciones del 
%offset del centro de fase de antena de receptor
% Dado un tiemo GPS, la posici�n de un sat�lite, la posici�n de receptor y los
% datos obtenidos de un archivo ANTEX calcula la correcci�n por varicaciones 
% del offset del centro de fase de la antena del receptor. Se implementan 
% variaciones dependientes tanto del �ngulo nadir, como del azimut.
% 
% ARGUMENTOS:
% 	r (3x1)		- Posici�n ECEF a-priori del receptor [m]
%	rj (3x1)	- Posici�n ECEF del sat�lite [m]
%	O_B2F (3x3) - Matriz de orientaci�n del receptor. Corresponde a la 
%				matriz de transformaci�n de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	tipoMed		- Tipo de medici�n a usar (clase TipoMedicion), para determinar 
%				la frecuencia en la que se desea el APC.
%	datosATX	- Estructura de datos provista por la funci�n leerArchivoANTEX
% 
% DEVOLUCI�N:		
%	pcvCorr		- Correcci�n por variaciones del offset del centro de fase 
%				de antena de sat�lite para el modelo de mediciones [m]


global IFC_A1 IFC_A2


% Busco la estructura que corresponde al sat�lite
NATX = length(datosATX);

% Busco las frecuencias que corresponden al tipo de medici�n
frec_indx = tipoMedicion2bandaFrecuencia(tipoMed);

% Si se pasa una sola estructura ANTEX se asume que es la correcta para la
% antena y el domo en cuesti�n
if NATX == 1
	
	flag_antena = strcmp(antena,datosATX.Antena);
	
	if ~flag_antena
		error('La antena no se corresponde a los datos ANTEX disponibles');
	end
	
	antexRec = datosATX;
else
	
	% Si est�n todos los datos del ANTEX los recorro buscando el correcto
	for nn = 1:NATX
		
		flag_antena = strcmp(antena,datosATX(nn).Antena);
		flag_domo = strcmp(domo,datosATX(nn).Domo);
		
		if flag_antena && flag_domo
			
			antexRec = datosATX(nn);
			break;
			
		end
		
	end
end


% Tengo que calcular los �ngulos de visi�n del sat�lite con respecto al marco de
% referencia del receptor

% Para ello calculo el vector l�nea de visi�n y lo roto al marco del receptor
ldv = rj - r;
ldv_B = O_B2F'*ldv;

% Este nuevo vector tiene toda la informaci�n para calcular los nuevos azimut y
% elevaci�n desde el punto de vista del cuerpo del receptor, por lo que puedo
% calcularlos directamente como si fueran coordenadas ENU reales
aer = enu2aer(ldv_B);

% Angulo de elevaci�n, azimut y de visi�n respecto al cenit
elev = aer(2);
azim = aer(1);
gamma = 90 - elev;

% Si no hay correcciones azimutales implemento solo las cenitales
if antexRec.NAZI == 0
	% Si no hay datos para esa elevaci�n (elevaci�n muy baja) salgo
	if gamma > antexRec.ZEN2
		pcvCorr = 0;
		return;
	end
	
	% Busco la calibraci�n m�s cercana redondeando hacia 0 (sumo 1 por la indexaci�n)
	zen_indx = 1 + floor(((gamma - antexRec.ZEN1)/antexRec.DZEN));
	
	% Busco el offset que corresponde a la/s frecuencias en cuesti�n y armo la
	% combinaci�n que corresponda en cada caso
	if length(frec_indx) == 1
		
		% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
		if (zen_indx == antexRec.NZEN) || (zen_indx == 1)
			pcvCorr = antexRec.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx);
		else
			diff = ((gamma - antexRec.ZEN1)/antexRec.DZEN) - (zen_indx - 1);
			
			pcvCorr = antexRec.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx)*(1 - diff) + antexRec.PCVZEN(frec_indx,SistemaGNSS.GPS,zen_indx+1)*diff;
		end
		
	% Combinaci�nes libres de ion�sfera
	elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
		
		% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
		if (zen_indx == antexRec.NZEN) || (zen_indx == 1)
			
			pcvCorr1 = antexRec.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx);
			pcvCorr2 = antexRec.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx);
			
			pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
			
		else
			diff = ((gamma - antexRec.ZEN1)/antexRec.DZEN) - (zen_indx - 1);
			
			pcvCorr1 = antexRec.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx)*(1 - diff) + antexRec.PCVZEN(frec_indx(1),SistemaGNSS.GPS,zen_indx+1)*diff;
			pcvCorr2 = antexRec.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx)*(1 - diff) + antexRec.PCVZEN(frec_indx(2),SistemaGNSS.GPS,zen_indx+1)*diff;
			
			pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
			
		end
		
	end
	
	return;
end


if gamma > antexRec.ZEN2
	pcvCorr = 0;
	return;
end



% En caso de haber correcciones azimutales uso estas

% Busco la calibraci�n m�s cercana redondeando hacia 0 (sumo 1 por la indexaci�n)
azi_indx = 1 + floor(((azim - antexRec.AZI1)/antexRec.DAZI));
zen_indx = 1 + floor(((gamma - antexRec.ZEN1)/antexRec.DZEN));

% Busco el offset que corresponde a la/s frecuencias en cuesti�n y armo la
% combinaci�n que corresponda en cada caso
if length(frec_indx) == 1
	
	% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
	if (zen_indx == antexRec.NAZI) || (zen_indx == 1)
		
		pcvCorr = antexSat.PCVAZI(frec_indx,SistemaGNSS.GPS,azi_indx,zen_indx);
		
	else
		
		diff = ((gamma - antexRec.ZEN1)/antexRec.DZEN) - (zen_indx - 1);
		
		pcvCorr = antexRec.PCVAZI(frec_indx,SistemaGNSS.GPS,azi_indx,zen_indx)*(1 - diff) + antexRec.PCVAZI(frec_indx,SistemaGNSS.GPS,azi_indx,zen_indx+1)*diff;
	
	end
	
% Combinaciones libres de ion�sfera
elseif tipoMed >= TipoMedicion.PIF && tipoMed <= TipoMedicion.PCIF
	
	% Si estoy en el inicio o fin del intervalo calibrado devuelvo el dato
	if (zen_indx == antexRec.NAZI) || (zen_indx == 1)
		
		pcvCorr1 = antexRec.PCVAZI(frec_indx(1),SistemaGNSS.GPS,azi_indx,zen_indx);
		pcvCorr2 = antexRec.PCVAZI(frec_indx(2),SistemaGNSS.GPS,azi_indx,zen_indx);
			
		pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
		
	else
		diff = ((gamma - antexRec.ZEN1)/antexRec.DZEN) - (zen_indx - 1);
		
		pcvCorr1 = antexRec.PCVAZI(frec_indx(1),SistemaGNSS.GPS,azi_indx,zen_indx)*(1 - diff) + antexRec.PCVAZI(frec_indx(1),SistemaGNSS.GPS,azi_indx,zen_indx+1)*diff;
		pcvCorr2 = antexRec.PCVAZI(frec_indx(2),SistemaGNSS.GPS,azi_indx,zen_indx)*(1 - diff) + antexRec.PCVAZI(frec_indx(2),SistemaGNSS.GPS,azi_indx,zen_indx+1)*diff;
		
		pcvCorr = IFC_A1*pcvCorr1 + IFC_A2*pcvCorr2;
			
	end
	
end

end

