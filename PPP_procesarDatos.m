function datosPPP = PPP_procesarDatos(datosObsRNX,datosNavRNX,datosSP3,datosCLK,datosSatATX,datosRecATX,datosEOP,configPPP)
%PPP_PROCESARDATOS Núcleo del procesamiento PPP
% Realiza el procesamiento para Posicionamiento Puntual Preciso en base a
% mediciones de pseudorango y fases de portadora (en principio, está la opción
% para poder hacerlo en forma configurable).
% 
% ARGUMENTOS:
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosNavRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de navegación.
% 	datosSP3	- Estructura de datos devuelta de la lectura de archivos SP3 de 
%				órbitas precisas correspondientes a 3 días concatenados.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de satélites GPS
%	datosSatATX - Arreglo de estructuras con los datos de antenas de satélites, 
%				leídos de un archivo ANTEX.
%	datosRecATX - Arreglo de estructuras con los datos de antenas de receptor, 
%				leídos de un archivo ANTEX.
% 	datosEOP	- Matriz con los datos leídos de un archivo de EOPs.
%	configPPP	- Estrucutura con parámetros de configuración establecidos por
%				el usuario.
% 
% DEVOLUCIÓN:
%	datosPPP	- Estructura de salida del procesamiento PPP.

load ConstantesGNSS.mat
load ConstantesTroposfera.mat
load ConstantesOrbitales.mat


h_barra = waitbar(0,'Procesando observables...','Name','PPP','CreateCancelBtn',...
	'setappdata(gcbf,''canceling'',1)');
waitObject = onCleanup(@() delete(h_barra));
setappdata(h_barra,'canceling',0)

if configPPP.PRODUCTOS_GNSS
	datosGNSS = datosSP3;
else
	datosGNSS = datosNavRNX;
end

KK = length(datosObsRNX.tR);

% Verifico que tengo todos los observables y datos de antena que necesito
datosObsRNX = verificarObservablesyCombinaciones(datosObsRNX,configPPP.GNSS,configPPP.OBSERVABLES);
datosRecATX = verificarDatosAntenaReceptor(datosRecATX,datosObsRNX.Antena,datosObsRNX.Domo);

% Genero la estructura para la salida
datosPPP = PPP_generarEstructuraSalida(KK,datosObsRNX,configPPP);

% Inicialización del filtro de Kalman
%	Una k significa época previa, kk significa época actual (al actualizar
%	temporalmente sería equivalente a k+1)
[xkk_prior,Pkk_prior,Qk] = PPP_inicializacionFiltro(datosObsRNX,datosGNSS,datosCLK,configPPP);

% Inicializo la matriz de orientación del receptor. Como PPP se aplica sobre
% estaciones terrestres fijas que se suponen bien orientadas esta siempre se
% corresponde a la matriz de transforamción entre ECEF y ENU
Orientacion = (ecef2enuMatriz(xkk_prior(1:3)))';

% Seguimiento de satélites (en general podría haber más de un GNSS)
datosSatelitesPrevios = generarEstructuraSatelites(0,configPPP.OBSERVABLES);


% Recorro cada época
for kk = 1:KK
	
	waitbar(kk/KK,h_barra,['Procesando época ' num2str(kk) ' de ' num2str(KK)]);
	
	if getappdata(h_barra,'canceling')
		break;
	end
	
	% Obtengo los satélites de la época actual
	datosSatelites = buscarSatelites(kk,datosObsRNX,configPPP);
	
	% Núcleo del procesamiento para obtener y modelar las mediciones GNSS
	datosSatelites = modelarSatelites(kk,datosSatelites,datosSatelitesPrevios,datosObsRNX,datosGNSS,datosCLK,datosSatATX,datosRecATX,datosEOP,xkk_prior(1:3),xkk_prior(4),xkk_prior(5),Orientacion,configPPP);
	
	% Edito datos y satélites para descartar mediciones
	datosSatelites = PPP_edicionDatos(datosSatelites,datosSatelitesPrevios,xkk_prior(1:3),xkk_prior(5),configPPP);
	
	% Reordeno el vector estado y la matriz de covarianza
	[xk_prior,Pk_prior] = PPP_reordenarEstados(datosSatelites,datosSatelitesPrevios,xkk_prior,Pkk_prior,configPPP);
	
	% Realizo la actualización observacional propiamente dicha
	[xk_post,Pk_post,datosSatelites] = PPP_actualizacionObservacional(datosSatelites,xk_prior,Pk_prior,configPPP);
	
	% Guardo los datos del modelo y la solución actual
	datosPPP = PPP_guardarDatosSolucion(kk,datosPPP,xk_post,Pk_post,xk_prior,datosSatelites,datosObsRNX,configPPP);
	
	% Realizo la actualización temporal
	[xkk_prior,Pkk_prior] = PPP_actualizacionTemporal(xk_post,Pk_post,Qk,configPPP);
	
	
	% Preparo el cambio de época
	datosSatelitesPrevios = datosSatelites;
	
end


h_msgbox = msgbox('Procesamiento finalizado con éxito','PPP');
uiwait(h_msgbox,10);
if ishandle(h_msgbox)
	delete(h_msgbox);
end

end