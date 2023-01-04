function [relCorrGen] = correccionRelativistaGeneral(r,rj)
%CORRECCIONRELATIVISTAGENERAL C�lculo de la correcci�n relativista general
% Calcula la correcci�n en el rango debido a la curvatura del espacio tiempo
% por causa del campo gravitatorio en base a la posici�n del receptor y la 
% posici�n del sat�lite.
% 
% ARGUMENTOS:
%	r  (3x1)	- Posici�n ECEF del receptor
%	rj (3x1)	- Posici�n ECEF del sat�lite GPS [m]
%
% DEVOLUCI�N:
%	relCorrGen	- Correcci�n relativista general [m]

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