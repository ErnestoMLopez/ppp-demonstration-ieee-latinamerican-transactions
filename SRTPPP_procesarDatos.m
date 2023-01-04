function datosSRTPPP = SRTPPP_procesarDatos(datosObsRNX,datosSP3,datosSatCLK,datosSatATX,datosRecATX,datosERP,configSRTPPP)
%SRTPPP_PROCESARDATOS Núcleo del procesamiento SRTPPP
% Realiza el procesamiento para Posicionamiento Puntual Preciso en Tiempo Real
% Simulado en base a mediciones de pseudorango y fases de portadora (en 
% principio, está la opción para poder hacerlo en forma configurable).
% 
% ARGUMENTOS:
%	datosRNX_OBS- Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
% 	datosSP3	- Arreglo de estructuras de datos devueltas de la lectura de 
%				archivos SP3 de órbitas precisas en tiempo real.
%	datosSatCLK	- Estructura de datos devuelta de la lectura de un archivo CLK 
%				de relojes precisos de satélites GPS en tiempo real
%	datosSatATX - Arreglo de estructuras con los datos de antenas de satélites, 
%				leídos de un archivo ANTEX.
%	datosRecATX - Arreglo de estructuras con los datos de antenas de receptor, 
%				leídos de un archivo ANTEX.
% 	datosERP	- Arreglo de estructuras devueltas de la lectura de archivos ERP
%				de parámetros de rotación de la Tierra ultra-rapid 
%				correspondientes al intervalo de tiempo de observables.
%	configSRTPPP- Estrucutura con parámetros de configuración establecidos por
%				el usuario.
% 
% DEVOLUCIÓN:
%	datosSRTPPP	- Estructura de salida del procesamiento SRTPPP.


h_barra = waitbar(0,'Procesando observables...','Name','SRTPPP','CreateCancelBtn',...
	'setappdata(gcbf,''canceling'',1)');
waitObject = onCleanup(@() delete(h_barra));
setappdata(h_barra,'canceling',0)


KK = length(datosObsRNX.tR);

% Verifico que tengo todos los observables y datos de antena que necesito
datosObsRNX = verificarObservablesyCombinaciones(datosObsRNX,configSRTPPP.GNSS,configSRTPPP.OBSERVABLES);
datosRecATX = verificarDatosAntenaReceptor(datosRecATX,datosObsRNX.Antena,datosObsRNX.Domo);

% Genero la estructura para la salida
datosSRTPPP = PPP_generarEstructuraSalida(KK,datosObsRNX,configSRTPPP);

% Inicialización del filtro de Kalman
%	Una k significa época previa, kk significa época actual (al actualizar
%	temporalmente sería equivalente a k+1)
[xkk_prior,Pkk_prior,Qk] = PPP_inicializacionFiltro(datosObsRNX,datosSP3,[],configSRTPPP);

% Inicializo la matriz de orientación del receptor. Como PPP se aplica sobre
% estaciones terrestres fijas que se suponen bien orientadas esta siempre se
% corresponde a la matriz de transforamción entre ECEF y ENU
Orientacion = (ecef2enuMatriz(xkk_prior(1:3)))';

% Seguimiento de satélites (en general podría haber más de un GNSS)
datosSatelitesPrevios = generarEstructuraSatelites(0,configSRTPPP.OBSERVABLES);


% Recorro cada época
for kk = 1:KK
	
	waitbar(kk/KK,h_barra,['Procesando época ' num2str(kk) ' de ' num2str(KK)]);
	
	if getappdata(h_barra,'canceling')
		break;
	end
	
	% Determino los productos ultra-rapid más recientes de ERP
	indx = QRTPPP_obtenerIndiceProductosUltraRapid(datosObsRNX.tR(kk),datosERP);
	
	% Obtengo los satélites de la época actual
	datosSatelites = buscarSatelites(kk,datosObsRNX,configSRTPPP);

	% Núcleo del procesamiento para obtener y modelar las mediciones GNSS
	datosSatelites = modelarSatelites(kk,datosSatelites,datosSatelitesPrevios,datosObsRNX,datosSP3,datosSatCLK,datosSatATX,datosRecATX,datosERP(indx),xkk_prior(1:3),xkk_prior(4),xkk_prior(5),Orientacion,configSRTPPP);

	% Edito datos y satélites para descartar mediciones
	datosSatelites = PPP_edicionDatos(datosSatelites,datosSatelitesPrevios,xkk_prior(1:3),xkk_prior(5),configSRTPPP);
	
	% Reordeno el vector estado y la matriz de covarianza
	[xk_prior,Pk_prior] = PPP_reordenarEstados(datosSatelites,datosSatelitesPrevios,xkk_prior,Pkk_prior,configSRTPPP);
	
	% Realizo la actualización observacional propiamente dicha
	[xk_post,Pk_post,datosSatelites] = PPP_actualizacionObservacional(datosSatelites,xk_prior,Pk_prior,configSRTPPP);
	
	% Guardo los datos del modelo y la solución actual
	datosSRTPPP = PPP_guardarDatosSolucion(kk,datosSRTPPP,xk_post,Pk_post,xk_prior,datosSatelites,datosObsRNX,configSRTPPP);
	
	% Realizo la actualización temporal
	[xkk_prior,Pkk_prior] = PPP_actualizacionTemporal(xk_post,Pk_post,Qk,configSRTPPP);
	
	
	% Preparo el cambio de época
	datosSatelitesPrevios = datosSatelites;
	
end


h_msgbox = msgbox('Procesamiento finalizado con éxito','SRTPPP');
uiwait(h_msgbox,10);
if ishandle(h_msgbox)
	delete(h_msgbox);
end


end



