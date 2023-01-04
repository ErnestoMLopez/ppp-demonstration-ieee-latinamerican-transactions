function arpCorr = correccionPuntoReferenciaAntena(r,rj,drARP)
%CORRECCIONPUNTOREFERENCIAANTENA Correcci�n por ARP para el modelo de mediciones
% Dado el offset del punto de referencia de la antena de receptor (especificado
% en el encabezado de los archivos RINEX de observables en el marco local ENU),
% calcula el t�rmino de correcci�n sobre las mediciones como la proyecci�n del
% offset sobre el vector l�nea de visi�n.
% 
% ARGUMENTOS:
%	r (3x1)		- Posici�n ECEF a-priori del receptor [m]
%	rj (3x1)	- Posici�n ECEF del sat�lite [m]
%	drARP (3x1) - Vector offset ARP en coordenadas locales ENU [m]
% 
% DEVOLUCI�N:		
%	arpCorr		- Correcci�n por el offset del punto de referencia de la antena 
%				de receptor para el modelo de mediciones.

% Obtengo el vector l�nea de visi�n unitario a-priori
LdV = (rj-r)./norm(rj-r);

% Obtengo el vector del offset APC ya en el marco ECEF
drARP = enu2ecefdif(drARP,r);

% Una vez obtenido el APC lo proyecto sobre el vector l�nea de visi�n unitario
arpCorr = -dot(LdV,drARP);

end