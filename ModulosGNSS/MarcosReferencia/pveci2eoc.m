function [eoc] = pveci2eoc(x_ECI)
%PVECI2EOC Elementos orbitales clásicos del satélite a partir del estado
%   Calcula los elementos orbitales clásicos del satélite a partir de la 
%	posición y la velocidad dados por el vector estado:
%	
% 		x_ECI	= (pu_ECI', v_ECI')'		[m; m/s]
%		eoc		= (a,e,i,Omega,omega,f)'	[m;-;rad;rad;rad;rad]
%	donde 
%		a = semieje mayor
%		e = excentricidad
%		i = inclinación
%		Omega = ascensión recta del nodo ascendente
%		omega = argumento del perigeo
%		f = anomalía verdadera
% 
% ARGUMENTOS:
%	x_ECI (6x1)	- Vector estado de posición y velocidad en un marco ECI
% 
% DEVOLUCIÓN:
%	eoc (6x1)	- Vector de elementos orbitales clásicos
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 24/01/2022

global MUE

% Valido la entrada, sino devuelvo NaN
if any(isnan(x_ECI))
	eoc = NaN(6,1);
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
	fav = acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
else
	fav = 2*pi - acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
end

if fav == 2*pi
	fav = 0;
end

% Agrupo todo en el vector de elementos orbitales
eoc = [sma,ecc,inc,Omg,omg,fav]';

end
