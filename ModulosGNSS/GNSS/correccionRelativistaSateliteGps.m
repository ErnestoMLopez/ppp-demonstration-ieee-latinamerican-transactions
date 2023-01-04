function [relCorr] = correccionRelativistaSateliteGps(rj,vj)
%CORRECCIONRELATIVISTASATELITEGPS C�lculo de la correcci�n relativista de reloj
%por excentricidad de un sat�lite GPS
% Calcula la correcci�n de reloj debido a la excentricidad de las �rbitas GPS
% y la teor�a de la relatividad especial en base a la posici�n y la velocidad
% del sat�lite obtenidas previamente ya sea mediante efem�rides u �rbitas
% precisas.
% 
% N�tese que a�n si el producto utilizado fue de efem�rides no se 
% utiliza la correcci�n mediante elementos orbitales (Ec. 2 de la secci�n 
% 20.3.3.3.3.1 del IS-GPS-200), sino la expresion alternativa utilizada por el 
% segmento de control (dada al final de la misma secci�n).
% 
% ARGUMENTOS:
%	rj (3x1)	- Posici�n ECEF del sat�lite GPS [m]
%	vj (3x1)	- Velocidad ECEF del sat�lite GPS [m]
% 
% DEVOLUCI�N:
%	relCorr		- Correcci�n relativista por excentricidad [s]

LUZ   = 2.99792458E8;

relCorr = -2*dot(rj,vj)./LUZ^2;

end
	