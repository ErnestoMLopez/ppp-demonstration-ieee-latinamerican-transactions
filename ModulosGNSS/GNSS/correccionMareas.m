function [mareascorr] = correccionMareas(t,r,rj,EOP)
%CORRECCIONMAREAS Correcci�n por desplazamientos del sitio debido a mareas
%   C�lculo de la correcci�n por mareas s�lidas terrestres (impelmentado), 
%	mareas oce�nicas (NO IMPLEMENTADO) y mareas polares (NO IMPLEMENTADO) 
%	aplicado al modelo de mediciones a trav�s de su proyecci�n sobre el vector 
%	l�nea de visi�n.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS [s]
%	r (3x1)		- Vector posici�n ECEF del usuario [m]
%	rj (3x1)	- Vector posici�n ECEF del sat�lite observado [m]
%	EOP			- Estructura con los par�metros de orientaci�n de la Tierra 
%				necesarios para las transformaciones ECI/ECEF en el c�lculo de 
%				las aceleraciones
% 
% DEVOLUCI�N:
%	mareascorr	- Correcci�n por mareas para el modelo de mediciones del
%				sat�lite observado. [m]


% Calculo el desplazamiento por mareas s�lidas y polares en la �poca dada
[dr_sol] = desplazamientoMareasSolidas(t,r);
[dr_pol] = desplazamientoMareasPolares(t,r,EOP);

dr = dr_sol + dr_pol;

% Proyecci�n sobre el vector l�nea visi�n unitario
LdV = (rj - r)./norm(rj - r);
mareascorr = -LdV'*dr;

end

