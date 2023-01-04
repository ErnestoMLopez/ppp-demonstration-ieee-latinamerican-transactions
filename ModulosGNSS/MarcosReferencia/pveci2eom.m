function [eom] = pveci2eom(x_ECI)
%PVECEF2EOM Elementos orbitales modificados del satélite a partir del estado
%   Calcula los elementos orbitales modificados del satélite a partir de la 
%	posición y la velocidad dados por el vector estado:
%	
% 		x_ECI	= (pu_ECI', v_ECI')'
%		alfa	= (a,u,ex,ey,i,Omega)'	[m;rad;-;-;rad;rad]
%	donde 
%		a = semieje mayor
%		u = argumento de la latitud medio
%		ex = vector excentricidad (componente x)
%		ey = vector excentricidad (componente x)
%		i = inclinación
%		Omega = ascensión recta del nodo ascendente
%	para más detalles ver [D'Amico 2010 PhD].
% 
% ARGUMENTOS:
%	x_ECI (6x1)	- Vector estado de posición y velocidad en un marco ECI
% 
% DEVOLUCIÓN:
%	alfa (6x1)	- Vector de elementos orbitales modificado
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 24/01/2022

global MUE

% Valido la entrada, sino devuelvo NaN
if any(isnan(x_ECI))
	eom = NaN(6,1);
	return;
end


r_ECI(1:3,1) = x_ECI(1:3);
v_ECI(1:3,1) = x_ECI(4:6);

% Vector momento angular
h = cross(r_ECI,v_ECI);

% Vector excentricidad
e = cross(v_ECI,h)/MUE - r_ECI/norm(r_ECI);

% Vector línea nodal
n = cross([0; 0; 1],h);

% Velocidad radial
vr = dot(r_ECI,v_ECI);

% Semieje mayor
sma = 1/((2/norm(r_ECI)) - (norm(v_ECI)^2/MUE));

% Excentricidad
ecc = norm(e);

% Inclinación
inc = acos(h(3)/norm(h));

% Ascensión recta del nodo ascendente
if n(2) >= 0
	Omg = acos(n(1)/norm(n));
else
	Omg = 2*pi - acos(n(1)/norm(n));
end

% Argumento del perigeo
if e(3) >= 0
	omg = acos(dot(n,e)/(norm(n)*norm(e)));
else
	omg = 2*pi - acos(dot(n,e)/(norm(n)*norm(e)));
end

% Anomalía verdadera
if vr >= 0
	av = acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
else
	av = 2*pi - acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
end

if av == 2*pi
	av = 0;
end

% Anomalía excéntrica
E = f2E(av, ecc);

% Anomalía media
M = E2M(E, ecc);

% Argumento de la latitud medio
u = omg + M;

% Componentes del vector excentricidad
ex = ecc*cos(omg);
ey = ecc*sin(omg);

% Agrupo todo en el vector de elementos orbitales
eom = [sma,u,ex,ey,inc,Omg]';

end
