function [x0,P0,Q0] = PPP_inicializacionFiltro(datosObs,datosSP3oNavRNX,datosCLK,configPPP)
%PPP_INICIALIZACIONFILTRO Inicialización de estado y matrices del KF para PPP
% 
% ARGUMENTOS:
%	datosObs	- Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosSP3oNavRNX - Estructura de datos devuelta de la lectura o bien de un 
%				archivo RINEX de navegación o de archivos SP3 de órbitas 
%				precisas.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de satélites GPS
%	configPPP	- Estrucutura con parámetros de configuración establecidos por
%				el usuario.
% 
% DEVOLUCIÓN:
%	x0 (5x1)	- Estado inicial del filtro. Incluye (rX;rY;rZ;cdtr;DZTDw)
%	P0 (5x5)	- Matriz de covarianza del error de estimación inicial
%	Q0 (5x5)	- Matriz de covarianza del ruido de proceso

%-------------------------------------------------------------------------------
if configPPP.INICIALIZAR_ESTADO_CON_RINEX
	
	% Posición a-priori
	r0 = datosObs.PosicionAprox;
	
	% Estimado del sesgo de reloj de receptor
	cdtr0 = 0;
	
	% Corrección del ZTD wet
	DZTDw0 = 0;
	
	% Vector estado inicial
	x0 = [r0; cdtr0; DZTDw0];
	
else
	
	% Si quiero inicializar el estado debo hallar una primera solución en frío
	navSol = PPP_obtenerSolucionEnFrio(1,datosObs,datosSP3oNavRNX,datosCLK,configPPP);
		
	% Vector estado inicial
	x0 = [navSol; 0];
	
end
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Matriz de covarianza inicial del error de estimación
P0 = eye(5);
P0(1:3,1:3) = configPPP.SIGMA_APRIORI_R^2.*eye(3);
P0(4,4) = configPPP.SIGMA_APRIORI_CDTR^2;
P0(5,5) = configPPP.SIGMA_APRIORI_DZTD^2;
%-------------------------------------------------------------------------------



%-------------------------------------------------------------------------------
% Matriz de covarianza del ruido de proceso
% El sesgo de reloj de receptor es tratado como un proceso de Wiener
qcdtr = (configPPP.SIGMA_CDTR^2*configPPP.T)/configPPP.TAU_CDTR;

% La corrección del retardo troposférico zenital húmedo es tratada como un
% proceso de Markov de 1er orden
F = exp(-configPPP.T/configPPP.TAU_DZTD);
qdztdw = configPPP.SIGMA_DZTD^2*(1-F^2);

Q0 = eye(5);
Q0(1:3,1:3) = configPPP.SIGMA_R^2.*eye(3);
Q0(4,4) = qcdtr;
Q0(5,5) = qdztdw;
%-------------------------------------------------------------------------------

end