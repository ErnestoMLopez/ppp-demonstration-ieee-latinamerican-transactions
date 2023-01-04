function arpCorr = correccionPuntoReferenciaAntena(r,rj,drARP)
%CORRECCIONPUNTOREFERENCIAANTENA Corrección por ARP para el modelo de mediciones
% Dado el offset del punto de referencia de la antena de receptor (especificado
% en el encabezado de los archivos RINEX de observables en el marco local ENU),
% calcula el término de corrección sobre las mediciones como la proyección del
% offset sobre el vector línea de visión.
% 
% ARGUMENTOS:
%	r (3x1)		- Posición ECEF a-priori del receptor [m]
%	rj (3x1)	- Posición ECEF del satélite [m]
%	drARP (3x1) - Vector offset ARP en coordenadas locales ENU [m]
% 
% DEVOLUCIÓN:		
%	arpCorr		- Corrección por el offset del punto de referencia de la antena 
%				de receptor para el modelo de mediciones.

% Obtengo el vector línea de visión unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drARP = enu2ecefdif(drARP,r);

% Una vez obtenido el APC lo proyecto sobre el vector línea de visión unitario
arpCorr = -dot(LdV,drARP);

end