function [x_ECI] = eoc2pveci(alfa)
%EOC2PVECI Estado del satélite con los elementos orbitales clásicos
%   Calcula la posición y velocidad del satélite con elementos orbitales 
%	dados por el vector alfa, definido como:
%	
%		alfa = (a,e,i,Omega,omega,f)'
%	
%	en el marco de referencia ECI, para lo cual primero calcula la
%	posición en el marco perifocal, luego mediante rotaciones la pasa al
%	marco ECI (en el que esten definidos los elementos orbitales)
% 
% ARGUMENTOS:
%	alfa (6x1)	- Vector de elementos orbitales clásicos
% 
% DEVOLUCIÓN:
%	x_ECEF (6x1)- Vector estado de posición y velocidad en el marco ECI

global MUE

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
v_PER = sqrt(MUE/(sma*(1-ecc^2)))*[-sin(fav); ecc + cos(fav); 0];

r_ECI = R3_Om'*R1_i'*R3_om'*r_PER;
v_ECI = R3_Om'*R1_i'*R3_om'*v_PER;

x_ECI = [r_ECI; v_ECI];

end

