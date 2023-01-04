function [alfa] = pvecef2eoc(x_ECEF,T_ECI2ECEF)
%PVECEF2EOC Elementos orbitales del sat�lite a partir del estado
%   Calcula los elementos orbitales del sat�lite a partir de la posici�n y 
%	la velocidad dados por el vector estado:
%	
% 		x_ECEF	= (pu_ECEF', v_ECEF')'
%		alfa	= (a,e,i,Omega,omega,f)'
%	
%	en el marco de referencia ECEF (realizaci�n dependiente de la 
%	transformaci�n pasada como par�metro, por ej. ITRF o WGS84, que son 
%	iguales al nivel de las decenas de cent�metros), para lo cual primero 
%	calcula la posici�n en el marco perifocal, luego mediante rotaciones la
%	pasa al marco ECI (su realizaci�n depende de en cual est�n definidos 
%	los elementos orbitales, por ej. ICRF o J2000) y en base a la matriz de 
%	transformaci�n entre ECI y ECEF pasada como argumento devuelve la 
%	posici�n en ECEF.
% 
% ARGUMENTOS:
%	x_ECEF (6x1)- Vector estado de posici�n y velocidad en el marco ECEF
%	T_ECI2ECEF	- Estructura con la matriz y submatrices de transformaci�n entre
%				realizaciones de los marcos ECI y ECEF, por ej. ICRF e ITRF
% 
% DEVOLUCI�N:
%	alfa (6x1)	- Vector de elementos orbitales cl�sicos

global WE MUE

% Valido la entrada, sino devuelvo NaN
if any(isnan(x_ECEF))
	alfa = NaN(6,1);
	return;
end


r_ECEF(1:3,1) = x_ECEF(1:3);
v_ECEF(1:3,1) = x_ECEF(4:6);


S = w2S([0;0;WE]);

% Transformaci�n de estado en ECEF al ECI
r_ECI = T_ECI2ECEF.T'\r_ECEF;
v_ECI = T_ECI2ECEF.T'\(v_ECEF + T_ECI2ECEF.W*S*T_ECI2ECEF.R*T_ECI2ECEF.Q*r_ECI);

% Vector momento angular
h = cross(r_ECI,v_ECI);

% Vector excentricidad
e = cross(v_ECI,h)/MUE - r_ECI/norm(r_ECI);

% Vector l�nea nodal
n = cross([0; 0; 1],h);

% Velocidad radial
vr = dot(r_ECI,v_ECI);

% Semieje mayor
sma = 1/((2/norm(r_ECI)) - (norm(v_ECI)^2/MUE));

% Excentricidad
ecc = norm(e);

% Inclinaci�n
inc = acos(h(3)/norm(h));

% Ascensi�n recta del nodo ascendente
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

% Anomal�a verdadera
if vr >= 0
	fav = acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
else
	fav = 2*pi - acos(dot(e,r_ECI)/(norm(e)*norm(r_ECI)));
end

if fav == 2*pi
	fav = 0;
end

% Agrupo todo en el vector de elementos orbitales
alfa = [sma,ecc,inc,Omg,omg,fav]';

end
