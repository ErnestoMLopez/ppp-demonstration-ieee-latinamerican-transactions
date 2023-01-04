function [mareascorr] = correccionMareas(t,r,rj,EOP)
%CORRECCIONMAREAS Corrección por desplazamientos del sitio debido a mareas
%   Cálculo de la corrección por mareas sólidas terrestres (impelmentado), 
%	mareas oceánicas (NO IMPLEMENTADO) y mareas polares (NO IMPLEMENTADO) 
%	aplicado al modelo de mediciones a través de su proyección sobre el vector 
%	línea de visión.
% 
% ARGUMENTOS:
%	t			- Tiempo GPS [s]
%	r (3x1)		- Vector posición ECEF del usuario [m]
%	rj (3x1)	- Vector posición ECEF del satélite observado [m]
%	EOP			- Estructura con los parámetros de orientación de la Tierra 
%				necesarios para las transformaciones ECI/ECEF en el cálculo de 
%				las aceleraciones
% 
% DEVOLUCIÓN:
%	mareascorr	- Corrección por mareas para el modelo de mediciones del
%				satélite observado. [m]


% Calculo el desplazamiento por mareas sólidas y polares en la época dada
[dr_sol] = desplazamientoMareasSolidas(t,r);
[dr_pol] = desplazamientoMareasPolares(t,r,EOP);

dr = dr_sol + dr_pol;

% Proyección sobre el vector línea visión unitario
LdV = (rj - r)./norm(rj - r);
mareascorr = -LdV'*dr;

end

