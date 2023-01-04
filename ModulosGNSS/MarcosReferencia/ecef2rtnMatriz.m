function [RECEF2RTN] = ecef2rtnMatriz(r0,v0)
%ECEF2RTNMATRIZ Matriz de rotaci�n al local RTN a partir de posici�n y velocidad ECEF
%   Calcula la matriz de rotaci�n al marco Radial-In-Track-Normal a partir de 
%	una posici�n y velocidad dadas en el marco ECEF.
% 
%	La transformaci�n requiere la conversi�n de la velocidad a un marco
%	inercial (se congela el ECEF) y luego el armado de la matriz de 
%	rotaci�n de la siguiente manera (ver por ej. S. D'Amico PhD):
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
%	r0 (3x1)	- Posici�n ECEF de referencia [m]
%	v0 (3x1) 	- Velocidad ECEF de referencia [m/s]
% 
% DEVOLUCION:
%	rtn (3x1)	- Coordenadas horizontales locales RTN [m]


% Velocidad de rotaci�n de la Tierra
WE  = 7.2921151467e-5; % WGS-84 value, rad/s

% Paso la velocidad al inercial
v0 = v0 + cross([0 0 WE]',r0);

eR = r0./norm(r0);
eN = cross(r0,v0)./norm(cross(r0,v0));
eT = cross(eN,eR)./norm(cross(eN,eR));

RECEF2RTN = [eR eT eN]';
	
end

