function [r_ECEF] = eoc2posecef(TECI_ECEF,alfa)
%EOC2POSECEF Posición del satélite con los elementos orbitales clásicos
%   Calcula la posición del satélite con elementos orbitales dados por el
%   vector alfa, definido como:
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


sma = alfa(1);
ecc = alfa(2);
inc = alfa(3);
Omg = alfa(4);
omg = alfa(5);
fav = alfa(6);

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

r_ECEF = TECI_ECEF*R3_Om'*R1_i'*R3_om'*r_PER;

end

