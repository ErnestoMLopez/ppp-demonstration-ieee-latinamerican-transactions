function [lla] = ecef2llaGeod(r)
%ECEF2LLAGEOD Latitud, longitud y alturas geodéticas desde posición ECEF

% ARGUMENTOS:
%	r (3x1)		- Vector posición ECEF [m]
%	
% DEVOLUCION:
%	lla (3x1)	- Latitud, longitud y altitud [º], [º], [m]

x = r(1);
y = r(2);
z = r(3);

% Parámetros del elipsoide WGS84
a = 6378137;
b = 6356752.3142;
e = sqrt(1-(b/a)^2);


lon = rad2deg(atan2(y,x));

p = sqrt(x^2 + y^2);

phi2 = atan((z/p)/(1 - e^2));
phi = 0;

while abs(phi2 - phi) > 1e-9
	
	phi = phi2;
	
	N = a/sqrt(1 - e^2*(sin(phi))^2);
	h = p/(cos(phi)) - N;
	
	phi2 = atan((z/p)/(1 - (N/(N+h))*e^2));
	
end

N = a/sqrt(1 - e^2*(sin(phi2))^2);
h = p/(cos(phi2)) - N;

lat = rad2deg(phi2);
alt = h;

lla = [lat; lon; alt];

end

