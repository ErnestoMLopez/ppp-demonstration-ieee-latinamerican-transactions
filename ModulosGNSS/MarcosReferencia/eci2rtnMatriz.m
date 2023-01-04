function [RECI2RTN] = eci2rtnMatriz(r0,v0)
%ECI2RTNMATRIZ Matriz de rotación al local RTN a partir de posición y velocidad ECI
%   Calcula la matriz de rotación al marco Radial-In-Track-Normal a partir de 
%	una posición y velocidad dadas en el marco inercial ECI.
% 
%	El armado de la matriz de rotación es de la siguiente manera (ver por ej. 
%	S. D'Amico PhD):
% 
%	p_I = p_F
%	v_I = v_F + (0; 0; WE)^T*p_F;
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
%	r0 (3x1)	- Posición ECEF de referencia [m]
%	v0 (3x1) 	- Velocidad ECEF de referencia [m/s]
% 
% DEVOLUCION:
%	rtn (3x1)	- Coordenadas horizontales locales RTN [m]


eR = r0./norm(r0);
eN = cross(r0,v0)./norm(cross(r0,v0));
eT = cross(eN,eR)./norm(cross(eN,eR));

RECI2RTN = [eR eT eN]';
	
end

