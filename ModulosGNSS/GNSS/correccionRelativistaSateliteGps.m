function [relCorr] = correccionRelativistaSateliteGps(rj,vj)
%CORRECCIONRELATIVISTASATELITEGPS Cálculo de la corrección relativista de reloj
%por excentricidad de un satélite GPS
% Calcula la corrección de reloj debido a la excentricidad de las órbitas GPS
% y la teoría de la relatividad especial en base a la posición y la velocidad
% del satélite obtenidas previamente ya sea mediante efemérides u órbitas
% precisas.
% 
% Nótese que aún si el producto utilizado fue de efemérides no se 
% utiliza la corrección mediante elementos orbitales (Ec. 2 de la sección 
% 20.3.3.3.3.1 del IS-GPS-200), sino la expresion alternativa utilizada por el 
% segmento de control (dada al final de la misma sección).
% 
% ARGUMENTOS:
%	rj (3x1)	- Posición ECEF del satélite GPS [m]
%	vj (3x1)	- Velocidad ECEF del satélite GPS [m]
% 
% DEVOLUCIÓN:
%	relCorr		- Corrección relativista por excentricidad [s]

LUZ   = 2.99792458E8;

relCorr = -2*dot(rj,vj)./LUZ^2;

end
	