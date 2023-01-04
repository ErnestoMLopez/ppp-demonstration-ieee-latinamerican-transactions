function [eom_T] = eoreom2eom(eor,eom_M)
%EOMDIF2EOR Elementos orbitales relativos a elem. orbitales modificados
%   Calcula los elementos orbitales modificados de un satélite TARGET a partir 
%	de los elementos orbitales modificados de un satélite MAIN y los elementos 
%	orbitales relativos (ROE [D'Amico 2010 PhD]).
% 
% 		eom		= (a,u,ex,ey,i,Omega)'			[m;rad;-;-;rad;rad]
%		eor		= (da,dlambda,dex,dey,dix,diy)' [-;rad;-;-;rad;rad]
%	donde 
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

da		= eor(1);
dlambda	= eor(2);
dex		= eor(3);
dey		= eor(4);
dix		= eor(5);
diy		= eor(6);

a_M		= eom_M(1);
u_M		= eom_M(2);
ex_M	= eom_M(3);
ey_M	= eom_M(4);
i_M		= eom_M(5);
Omega_M	= eom_M(6);

a_T		= a_M + a_M*da;
Omega_T = Omega_M + diy/sin(i_M);
u_T		= u_M - (Omega_T-Omega_M)*cos(i_M) + dlambda;
ex_T	= ex_M + dex;
ey_T	= ey_M + dey;
i_T		= i_M + dix;

eom_T = [a_T u_T ex_T ey_T i_T Omega_T]';

end