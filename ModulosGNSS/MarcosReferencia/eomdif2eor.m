function [eor] = eomdif2eor(eom_M,eom_T)
%EOMDIF2EOR Elementos orbitales relativos partir de elem. orbitales modificados
%   Calcula los elementos orbitales relativos (ROE [D'Amico 2010 PhD]) de un 
%	satélite TARGET con respecto a otro MAIN a partir de los elementos orbitales
%	modificados de cada uno.
% 
% 		eom		= (a,u,ex,ey,i,Omega)'			[m;rad;-;-;rad;rad]
%		eor		= (da,dlambda,dex,dey,dix,diy)' [-;rad;-;-;rad;rad]
% 
%	donde 
% 
%		a = semieje mayor
%		u = argumento de la latitud medio
%		ex = vector excentricidad (componente x)
%		ey = vector excentricidad (componente x)
%		i = inclinación
%		Omega = ascensión recta del nodo ascendente
% 
%		da = semieje mayor relativo
%		dlambda = longitud relativa media
%		dex = vector excentricidad relativa (componente x)
% 		dey = vector excentricidad relativa (componente y)
%		dix = vector inclinación relativa (componente x)
%		diy = vector inclinación relativa (componente y)
% 
%	para más detalles ver [D'Amico 2010 PhD].
% 
% ARGUMENTOS:
%	eom_M (6x1)	- Vector de elementos orbitales modificado del satélite MAIN
%	eom_T (6x1)	- Vector de elementos orbitales modificado del satélite TARGET
% 
% DEVOLUCIÓN:
%	eor (6x1)	- Vector de elementos orbitales relativo
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 24/01/2022

a_M		= eom_M(1);
u_M		= eom_M(2);
ex_M	= eom_M(3);
ey_M	= eom_M(4);
i_M		= eom_M(5);
Omega_M	= eom_M(6);

a_T		= eom_T(1);
u_T		= eom_T(2);
ex_T	= eom_T(3);
ey_T	= eom_T(4);
i_T		= eom_T(5);
Omega_T	= eom_T(6);

da		= (a_T-a_M)/a_M;
dlambda = (u_T-u_M) + (Omega_T-Omega_M)*cos(i_M);
dex		= ex_T - ex_M;
dey		= ey_T - ey_M;
dix		= i_T - i_M;
diy		= (Omega_T-Omega_M)*sin(i_M);

eor = [da dlambda dex dey dix diy]';

end