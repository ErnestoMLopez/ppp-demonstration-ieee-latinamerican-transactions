function [x_ECEF] = eoc2pvecef(alfa,T_ECI2ECEF)
%EOC2PVECEF Estado del satélite con los elementos orbitales clásicos
%   Calcula la posición y la velocidad del satélite con elementos orbitales 
%	dados por el vector alfa, definido como:
%	
%		alfa = (a,e,i,Omega,omega,f)'
%	
%	en el marco de referencia ECEF (realización dependiente de la 
%	transformación pasada como parámetro, por ej. ITRF o WGS84, que son 
%	iguales al nivel de las decenas de centímetros), para lo cual primero 
%	calcula la posición en el marco perifocal, luego mediante rotaciones la
%	pasa al marco ECI (su realización depende de en cual están definidos 
%	los elementos orbitales, por ej. ICRF o J2000) y en base a la matriz de 
%	transformación entre ECI y ECEF pasada como argumento devuelve la 
%	posición en ECEF.
% 
% ARGUMENTOS:
%	alfa (6x1)	- Vector de elementos orbitales clásicos
%	T_ECI2ECEF	- Estructura con la matriz y submatrices de transformación entre
%				realizaciones de los marcos ECI y ECEF, por ej. ICRF e ITRF
% 
% DEVOLUCIÓN:
%	x_ECEF (6x1)- Vector estado de posición y velocidad en el marco ECEF dado

global WE MUE

sma = alfa(1);	% Semieje mayor
ecc = alfa(2);	% Excentricidad
inc = alfa(3);	% Inclinación
Omg = alfa(4);	% Longitud recta del nodo ascendente
omg = alfa(5);	% Argumento del perigeo
fav = alfa(6);	% Anomalía verdadera

coso = cos(omg); sino = sin(omg);
cosO = cos(Omg); sinO = sin(Omg);
cosi = cos(inc); sini = sin(inc);


R3_om = [ coso	sino	0; ...
		 -sino	coso	0; ...
		  0		0		1];
	  
R3_Om = [ cosO	sinO	0; ...
		 -sinO	cosO	0; ...
		  0		0		1];
	  
R1_i = [1	0		0; ...
		0	cosi	sini; ...
		0  -sini	cosi];
	
 	 
r_PER = (sma*(1-ecc^2)/(1+ecc*cos(fav)))*[cos(fav); sin(fav); 0];
v_PER = sqrt(MUE/(sma*(1-ecc^2)))*[-sin(fav); ecc + cos(fav); 0];

r_ECI = R3_Om'*R1_i'*R3_om'*r_PER;
v_ECI = R3_Om'*R1_i'*R3_om'*v_PER;

r_ECEF = T_ECI2ECEF.T*r_ECI;
v_ECEF = T_ECI2ECEF.T*v_ECI - T_ECI2ECEF.W*cross([0;0;WE],r_ECEF);

x_ECEF = [r_ECEF; v_ECEF];

end

