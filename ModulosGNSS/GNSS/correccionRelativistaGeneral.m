function [relCorrGen] = correccionRelativistaGeneral(r,rj)
%CORRECCIONRELATIVISTAGENERAL Cálculo de la corrección relativista general
% Calcula la corrección en el rango debido a la curvatura del espacio tiempo
% por causa del campo gravitatorio en base a la posición del receptor y la 
% posición del satélite.
% 
% ARGUMENTOS:
%	r  (3x1)	- Posición ECEF del receptor
%	rj (3x1)	- Posición ECEF del satélite GPS [m]
%
% DEVOLUCIÓN:
%	relCorrGen	- Corrección relativista general [m]

global MUE LUZ

if length(r) == 1
	relCorrGen = 0;
else
	rr   = norm(r);
	rjrj = norm(rj);
	rjr  = norm(rj-r);
	aux = (rr + rjrj + rjr) / (rr + rjrj - rjr);
	relCorrGen = 2*MUE/(LUZ^2)*log((aux));
end
	
end