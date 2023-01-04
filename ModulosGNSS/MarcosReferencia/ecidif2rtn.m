function [rtn] = ecidif2rtn(r,r0,v0)
%ECIDIF2RTN Coordenadas locales RTN a partir de posición y velocidad ECI
%   Calcula las coordenadas en el marco Radial-In-Track-Normal de una
%   posición dada en el marco ECI respecto a otro cuerpo referencia en una
%   posición y velocidad dadas en el marco ECI.
% 
%	e_R = p/||p||
%	e_N = (p X v)/||p X v||
% 	e_T = e_N X e_R
% 
%	R_ECI2RTN = [e_R e_t e_N]^T
% 
%	donde los vectores unitarios son vectores columnas
% 
% 
% ARGUMENTOS:
%	r (3x1)		- Posición ECI [m]
%	r0 (3x1)	- Posición ECI de referencia [m]
%	v0 (3x1)	- Velocidad ECI de referencia [m/s]
% 
% DEVOLUCION:
%	rtn (3x1)	- Coordenadas horizontales locales RTN [m]

RECI2RTN = eci2rtnMatriz(r0,v0);

rrel = r - r0;

rtn = RECI2RTN*rrel;

end

