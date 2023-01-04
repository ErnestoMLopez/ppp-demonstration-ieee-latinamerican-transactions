function [ps,vs,healthy] = calcularEstadoSateliteGps_SP3(t,PRN,datosSP3)
%CALCULARESTADOSATELITEGPS_SP3 C�mputo del estado de un sat�lite GPS(marco ECEF)
% A partir de las posiciones precisas de cada sat�lite provistas en el archivo 
% SP3 la funci�n devuelve la posici�n y velocidad del sat�lite pedido en el 
% marco ECEF en base a una interpolaci�n trigonom�trica. El estado calculado 
% corresponde solo al centro de masa del sat�lite.
%
% Dicha interpolaci�n de 9 puntos, est� dada por la siguiente expresi�n:
%	C = A0 + A1 sin(wt) + A2 cos(wt) + A3 sin(2wt) + A4 cos(2wt) +
%		A5 sin(3wt) + A6 cos(3wt) + A7 sin(4wt) + A8 cos(4wt)
%
% Donde w = 2*pi*1.00273781191135448 rad/d�a, y la constante es la
% relaci�n entre un d�a solar y un d�a sid�reo.
% 
% En caso de que el paso de muestreo sea de 30 segundos se asume que se trata de
% datos correspondientes a productos igc de tiempo real, por lo que se aplica
% una interpolaci�n de Lagrange de los 4 puntos previos para su correcta
% aplicaci�n a tiempo real
%
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n.
%	PRN			- PRN del sat�lite del que se desea calcular su posici�n
%	datosSP3	- Estructura de datos provista por la funci�n leerArchivoSP3 
%				a partir de un archivo de �rbitas precisas.
%
% DEVOLUCI�N:
%	ps (3x1) -	Posici�n en el marco ECEF para el tiempo GPS dado [m]
%	vs (3x1) -	Velocidad en el marco ECEF para el tiempo GPS dado [m/s]
%	healthy -	Indicador de validez (1) o no (0) del sat�lite

%==========================================================================
% Constantes
%==========================================================================
w = 2*pi*1.00273781191135448/(24*60*60);

%==========================================================================
% Inicializaci�n variables de salida
%==========================================================================
ps		= NaN(3,1);
vs		= NaN(3,1);
healthy = false;

datos = datosSP3.data;
columnaTGPS = datosSP3.col.TGPS;
columnaPRN = datosSP3.col.PRN;
columnaX = datosSP3.col.X;
columnaY = datosSP3.col.Y;
columnaZ = datosSP3.col.Z;

% Busco entre todas las posiciones las que corresponden al sat�lite deseado
listaPRN = datos(:,columnaPRN);
indx = listaPRN == PRN;

if all(~indx)
	fprintf('No se encuentra el satelite buscado: PRN = %d\n', PRN)
	return					% Si no se encuentra nada retorna NaNs
end

% Dejo solo las entradas de ese sat�lite
satposPRN = datos(indx,:);
MM = size(satposPRN,1);

% Obtengo el paso de muestreo de las �rbitas precisas
T = satposPRN(2,columnaTGPS) - satposPRN(1,columnaTGPS);


% Calculo del tiempo transcurrido entre cada tiempo de entrada y cada instante 
% del cual se dispone la posici�n precisa
dt_in_sats = t - satposPRN(:,columnaTGPS);

% Detecto el instante (pto_central) m�s cercano al de entrada del cual poseo 
% informaci�n precisa
[~,pto_central] = min(abs(dt_in_sats));


% Si tengo el paso de muestreo es de 30 segundos los datos corresponden a un 
% archivo SP3 de productos igc, de la decodificaci�n de streams en tiempo real. 
% Entonces extrapolo con polinomio de Langrange a partir de los �ltimos 4 (o
% menos) puntos disponibles para mantener la filosof�a del tiempo real
if T == 30
	
	% Determino la cantidad de puntos previos que tengo
	if pto_central == 1
		return;
	else
		if pto_central > 4
			NN = 4;
		else
			NN = pto_central;
		end
		n0 = pto_central;
	end
	
	% Obtengo los valores correspondientes a las 4 �ltimas muestras
	xn = satposPRN(n0-(NN-1):n0,columnaX);
	yn = satposPRN(n0-(NN-1):n0,columnaY);
	zn = satposPRN(n0-(NN-1):n0,columnaZ);
	
	% Armo los instantes de tiempos absolutos de los puntos interpolantes
	tn = satposPRN(n0-(NN-1):n0,columnaTGPS);
	tn0 = satposPRN(n0,columnaTGPS);
	dt0 = t - tn0;
	
	% Verifico 2 cosas: que las muestras que poseo no tengan gaps de datos 
	% durante un intervalo mayor al de muestreo, y que tampoco sean muy antiguas 
	% para extrapolar de forma correcta
	if (max(diff(tn)) > T) || (abs(dt0) > T)
		return;
	end
	
	[ps,vs] = interpolacionLagrangeOrbitas(t,tn,xn,yn,zn);


% En caso contrario supongo que se trata de un archivo SP3 de productos finales,
% r�pidos o ultra-r�pidos, por lo que interpolo mediante polinomio
% trigonom�trico de 9 puntos
elseif T == 900
	
	% Caso interpolaci�n:
	if (pto_central > 4) && (pto_central <= (MM-4))
		n0 = pto_central;
	% Caso extrapolaci�n hacia el d�a previo:
	elseif pto_central <= 4
		n0 = 5;
	% Caso extrapolaci�n hacia el d�a siguiente:
	elseif pto_central > MM-4
		n0 = MM - 4;
	end
	
	% Armo los vectores de entrada al sistema lineal
	xn = satposPRN((n0-4):(n0+4),columnaX);
	yn = satposPRN((n0-4):(n0+4),columnaY);
	zn = satposPRN((n0-4):(n0+4),columnaZ);
	
	% Armo los instantes de tiempos absolutos de los puntos interpolantes
	tn = satposPRN((n0-4):(n0+4),columnaTGPS);
	tn0 = satposPRN(n0,columnaTGPS);
	dt0 = t - tn0;
	
	% Verifico que las �rbitas no posean gaps mayores a una muestra faltante, y
	% adem�s que la distancia de la �poca al punto central no sea mayor a 5T (la
	% distancia correspondiente a una extrapolaci�n solo una muestra por fuera
	% de los puntos). Estas condiciones son m�s relajadas que las del polinomio
	% debido a la mejor calidad de interpolaci�n
	if (max(diff(tn)) > 2*T) || (abs(dt0) > 5*T)
		return;
	end
	
	[ps,vs] = interpolacionTrigonometricaOrbitas(t,tn,xn,yn,zn,w);
	
% Si el paso no es ninguno de los anteriores rechazo el sat�lite por las dudas
else
	
	return;
	
end

healthy = true;

end
