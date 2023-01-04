function [clkCorr] = calcularCorreccionRelojSateliteGps_CLK(t,PRN,datosCLK)
%CALCULARCORRECCIONRELOJSATELITEGPS_CLK Obtiene la corrección de reloj de un satélite GPS
% Obtiene la corrección de reloj de satélite en base a los datos precisos
% provistos por archivos CLK o CLK_30S. En caso de ser necesario se utiliza
% interpolación lineal, sino se utilizan los datos en forma directa de la
% tabla
%
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición.
%	PRN			- PRN del satélite del que se desea calcular su posición
%	datosCLK	- Estructura de datos provista por la función leerArchivoCLK a
%				partir de un archivo de relojes precisos.
%
% DEVOLUCIÓN:
%	clkCorr		- Corrección de sesgo de reloj de satélite en el tiempo dado [s]

clkCorr = NaN;

datos = datosCLK.data;
columnaPRN = datosCLK.col.PRN;
columnaTGPS = datosCLK.col.TGPS;
columnaCLKERR = datosCLK.col.CLKERR;

% Busco entre todas las posiciones las que corresponden al satélite deseado
listaPRN = datos(:,columnaPRN);
indx = listaPRN == PRN;

if all(~indx)
	fprintf('No se encuentra el satelite buscado: PRN = %d\n', PRN)
	return;					% Si no se encuentra nada retorna NaNs
end

% Dejo solo las entradas de ese satélite
satclkPRN = datos(indx,:);

MM = size(satclkPRN,1);

dt_in_sats = t - satclkPRN(:,columnaTGPS);

% Detecto el instante (pto_central) más cercano al de entrada del cual
% poseo información precisa
[~,pto_central] = min(abs(dt_in_sats));

delta_t = dt_in_sats(pto_central);

% Si estoy a la misma tasa de muestreo que los relojes no interpolo solo utilizo 
% el dato directamente (lo correcto), en caso de tener relojes a una tasa menor 
% a la que se desea entonces voy a tener que interpolar sí o sí. En ese caso no 
% debería haber problema con los extremos del día porque siempre coinciden con 
% una muestra de relojes, sean a la tasa que sean
if abs(delta_t) < 100E-3
	clkCorr = satclkPRN(pto_central, columnaCLKERR);
elseif (delta_t > 0) && (pto_central < MM)
	t_central = satclkPRN(pto_central, columnaTGPS);
	t_sig = satclkPRN(pto_central+1, columnaTGPS);
	
	% Pendiente de la recta de interpolación
	m = ((satclkPRN(pto_central+1, columnaCLKERR) - ...
		satclkPRN(pto_central, columnaCLKERR)) / ...
		(t_sig - t_central));
	
	clkCorr = satclkPRN(pto_central, columnaCLKERR) + m*delta_t;
elseif (delta_t < 0) && (pto_central > 1)
	t_central = satclkPRN(pto_central, columnaTGPS);
	t_ant = satclkPRN(pto_central-1, columnaTGPS);
	
	m = ((satclkPRN(pto_central, columnaCLKERR) - ...
		satclkPRN(pto_central-1, columnaCLKERR)) / ...
		(t_central - t_ant));
	
	clkCorr = satclkPRN(pto_central, columnaCLKERR) + m*delta_t;
else
	clkCorr = NaN;
end

end