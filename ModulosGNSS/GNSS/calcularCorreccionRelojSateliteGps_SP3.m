function [clkCorr] = calcularCorreccionRelojSateliteGps_SP3(t,PRN,datosSP3)
%CALCULARCORRECCIONRELOJSATELITEGPS_SP3 Obtiene la corrección de reloj de un satélite GPS
% Obtiene la corrección de reloj de satélite en base a los datos precisos
% provistos por archivos SP3 a una tasa de 15 minutos, por lo que se utiliza
% interpolación lineal.
%
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición.
%	PRN			- PRN del satélite del que se desea calcular su posición
%	datosSP3	- Estructura de datos provista por la función leerArchivoSP3 a
%				partir de un archivo de órbitas	precisas.
%
% DEVOLUCIÓN:
%	clkCorr		- Corrección de sesgo de reloj de satélite en el tiempo dado [s]

clkCorr = NaN;

datos = datosSP3.data;
columnaTGPS = datosSP3.col.TGPS;
columnaPRN = datosSP3.col.PRN;
columnaCLKERR = datosSP3.col.CLKERR;

% Busco entre todas las posiciones las que corresponden al satélite deseado
listaPRN = datos(:,columnaPRN);
indx = listaPRN == PRN;

if all(~indx)
	fprintf('No se encuentra el satelite buscado: PRN = %d\n', PRN)
	return;					% Si no se encuentra nada retorna NaNs
end


satsp3PRN = datos(indx,:);
MM = size(satsp3PRN,1);

dt_in_clks = t - satsp3PRN(:,columnaTGPS);

[~,pto_central] = min(abs(dt_in_clks));
delta_t = dt_in_clks(pto_central);

% Si estoy a la misma tasa de muestreo que los relojes no interpolo solo utilizo 
% el dato directamente (lo correcto), en caso de tener relojes a una tasa menor 
% a la que se desea entonces voy a tener que interpolar sí o sí. En ese caso no 
% debería haber problema con los extremos del día porque siempre coinciden con 
% una muestra de relojes, sean a la tasa que sean
if abs(delta_t) < 100E-3
	clkCorr = satsp3PRN(pto_central, columnaCLKERR);
elseif (delta_t > 0) && (pto_central < MM)
	t_central = satsp3PRN(pto_central, columnaTGPS);
	t_sig = satsp3PRN(pto_central+1, columnaTGPS);
	
	% Pendiente de la recta de interpolación
	m = ((satsp3PRN(pto_central+1, columnaCLKERR) - ...
		satsp3PRN(pto_central, columnaCLKERR)) / ...
		(t_sig - t_central));
	
	clkCorr = satsp3PRN(pto_central, columnaCLKERR) + m*delta_t;
else
	t_central = satsp3PRN(pto_central, columnaTGPS);
	t_ant = satsp3PRN(pto_central-1, columnaTGPS);
	
	m = ((satsp3PRN(pto_central, columnaCLKERR) - ...
		satsp3PRN(pto_central-1, columnaCLKERR)) / ...
		(t_central - t_ant));
	
	clkCorr = satsp3PRN(pto_central, columnaCLKERR) + m*delta_t;
end

end