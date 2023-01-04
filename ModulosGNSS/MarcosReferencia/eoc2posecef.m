function [r_ECEF] = eoc2posecef(TECI_ECEF,alfa)
%EOC2POSECEF Posici�n del sat�lite con los elementos orbitales cl�sicos
%   Calcula la posici�n del sat�lite con elementos orbitales dados por el
%   vector alfa, definido como:
%	
%		alfa = (a,e,i,Omega,omega,f)'
%	
%	en el marco de referencia ECEF (realizaci�n dependiente de la 
%	transformaci�n pasada como par�metro, por ej. ITRF o WGS84, que son 
%	iguales al nivel de las decenas de cent�metros), para lo cual primero 
%	calcula la posici�n en el marco perifocal, luego mediante rotaciones la
%	pasa al marco ECI (su realizaci�n depende de en cual est�n definidos 
%	los elementos orbitales, por ej. ICRF o J2000) y en base a la matriz de 
%	transformaci�n entre ECI y ECEF pasada como argumento devuelve la 
%	posici�n en ECEF.


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

