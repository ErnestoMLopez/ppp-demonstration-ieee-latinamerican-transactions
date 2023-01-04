function datosPPP = PPP_procesarDatos(datosObsRNX,datosNavRNX,datosSP3,datosCLK,datosSatATX,datosRecATX,datosEOP,configPPP)
%PPP_PROCESARDATOS N�cleo del procesamiento PPP
% Realiza el procesamiento para Posicionamiento Puntual Preciso en base a
% mediciones de pseudorango y fases de portadora (en principio, est� la opci�n
% para poder hacerlo en forma configurable).
% 
% ARGUMENTOS:
%	datosObsRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de observables.
%	datosNavRNX - Estructura de datos devuelta de la lectura de un archivo RINEX
%				de navegaci�n.
% 	datosSP3	- Estructura de datos devuelta de la lectura de archivos SP3 de 
%				�rbitas precisas correspondientes a 3 d�as concatenados.
%	datosCLK	- Estructura de datos devuelta de la lectura de un archivo CLK o
%				CLK_30S de relojes de sat�lites GPS
%	datosSatATX - Arreglo de estructuras con los datos de antenas de sat�lites, 
%				le�dos de un archivo ANTEX.
%	datosRecATX - Arreglo de estructuras con los datos de antenas de receptor, 
%				le�dos de un archivo ANTEX.
% 	datosEOP	- Matriz con los datos le�dos de un archivo de EOPs.
%	configPPP	- Estrucutura con par�metros de configuraci�n establecidos por
%				el usuario.
% 
% DEVOLUCI�N:
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

% Inicializaci�n del filtro de Kalman
%	Una k significa �poca previa, kk significa �poca actual (al actualizar
%	temporalmente ser�a equivalente a k+1)
[xkk_prior,Pkk_prior,Qk] = PPP_inicializacionFiltro(datosObsRNX,datosGNSS,datosCLK,configPPP);

% Inicializo la matriz de orientaci�n del receptor. Como PPP se aplica sobre
% estaciones terrestres fijas que se suponen bien orientadas esta siempre se
% corresponde a la matriz de transforamci�n entre ECEF y ENU
Orientacion = (ecef2enuMatriz(xkk_prior(1:3)))';

% Seguimiento de sat�lites (en general podr�a haber m�s de un GNSS)
datosSatelitesPrevios = generarEstructuraSatelites(0,configPPP.OBSERVABLES);


% Recorro cada �poca
for kk = 1:KK
	
	waitbar(kk/KK,h_barra,['Procesando �poca ' num2str(kk) ' de ' num2str(KK)]);
	
	if getappdata(h_barra,'canceling')
		break;
	end
	
	% Obtengo los sat�lites de la �poca actual
	datosSatelites = buscarSatelites(kk,datosObsRNX,configPPP);
	
	% N�cleo del procesamiento para obtener y modelar las mediciones GNSS
	datosSatelites = modelarSatelites(kk,datosSatelites,datosSatelitesPrevios,datosObsRNX,datosGNSS,datosCLK,datosSatATX,datosRecATX,datosEOP,xkk_prior(1:3),xkk_prior(4),xkk_prior(5),Orientacion,configPPP);
	
	% Edito datos y sat�lites para descartar mediciones
	datosSatelites = PPP_edicionDatos(datosSatelites,datosSatelitesPrevios,xkk_prior(1:3),xkk_prior(5),configPPP);
	
	% Reordeno el vector estado y la matriz de covarianza
	[xk_prior,Pk_prior] = PPP_reordenarEstados(datosSatelites,datosSatelitesPrevios,xkk_prior,Pkk_prior,configPPP);
	
	% Realizo la actualizaci�n observacional propiamente dicha
	[xk_post,Pk_post,datosSatelites] = PPP_actualizacionObservacional(datosSatelites,xk_prior,Pk_prior,configPPP);
	
	% Guardo los datos del modelo y la soluci�n actual
	datosPPP = PPP_guardarDatosSolucion(kk,datosPPP,xk_post,Pk_post,xk_prior,datosSatelites,datosObsRNX,configPPP);
	
	% Realizo la actualizaci�n temporal
	[xkk_prior,Pkk_prior] = PPP_actualizacionTemporal(xk_post,Pk_post,Qk,configPPP);
	
	
	% Preparo el cambio de �poca
	datosSatelitesPrevios = datosSatelites;
	
end


h_msgbox = msgbox('Procesamiento finalizado con �xito','PPP');
uiwait(h_msgbox,10);
if ishandle(h_msgbox)
	delete(h_msgbox);
end

end