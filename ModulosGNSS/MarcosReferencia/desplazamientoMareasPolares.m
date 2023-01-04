function [dr] = desplazamientoMareasPolares(t,r,EOP)
%DESPLAZAMIENTOMAREASPOLARES Desplazamiento de sitio por mareas polares
%   A partir de la posición a priori de un receptor en una estación terrestre en
%	una época dada calcula el desplazamiento del sitio debido a las mareas
%	polares. Basado en [IERS Conventions, 2010] y [Springer Handbook 
% 	of GNSS]
% 
% ARGUMENTOS:
%	t			- Tiempo GPS [s]
% 	r (3x1)		- Vector posición de una estación en el marco ECEF [m]
%	EOP			- Estructura con los parámetros de orientación de la 
%				Tierra necesarios para las transformaciones ECI/ECEF en
%				el cálculo de las aceleraciones
% 
% DEVOLUCION:
%	dr (3x1)	- Desplazamiento debido a las mareas sólidas terrestres en
%				el marco ECEF [m] 	


% Convierto a UTC
YYYY = gpsTime2utcTime(t);

%-------------------------------------------------------------------------------
% Tabla 7.7 de [IERS 2010] para el calculo del polo medio [m''/año^i]
%-------------------------------------------------------------------------------
if YYYY < 2010
	xp_i_mean = [55.974; ...
				1.8243; ...
				0.18413; ...
				0.007024];
	yp_i_mean = [346.346; ...
				1.7896; ...
				-0.10729; ...
				-0.000908];
else
	xp_i_mean = [23.513; ...
				7.6141; ...
				0.0; ...
				0.0];
	yp_i_mean = [358.891; ...
				-0.6287; ...
				0.0; ...
				0.0];
end
%-------------------------------------------------------------------------------

x = r(1);
y = r(2);
z = r(3);
rr = norm(r);


% Calculo la latitud geocéntrica (phi) y la longitud (lambda)
sinphi = z/rr;
phi = asin(sinphi);
lambda = atan2(y,x);

% Y con ella la colatitud theta
theta = pi/2 - phi;

% Calculo el t0 para hallar el polo medio modelo IERS (en años julianos)
jy2000 = ymd2jdn(2000,1,1)/365.25;
jy = gpsTime2utcJd(t)/365.25;

% Calculo el polo medio [m'']
xp_mean = 0;
yp_mean = 0;
for ii = 0:3
	xp_mean = xp_mean + (jy - jy2000)^ii*xp_i_mean(ii+1)^ii;
	yp_mean = yp_mean + (jy - jy2000)^ii*yp_i_mean(ii+1)^ii;
end
xp_mean = xp_mean/1000;	% Paso a ['']
yp_mean = yp_mean/1000;

% Paso las coordenadas del polo de los EOP a ['']
xp = EOP.pm.x*(180*3600/pi);
yp = EOP.pm.y*(180*3600/pi);

% Parámetros m
m1 = xp - xp_mean;
m2 = -(yp - yp_mean);

% Funciones de los ángulos
costheta = cos(theta);
cos2theta = cos(2*theta);
sentheta = sin(theta);
sen2theta = sin(2*theta);
coslambda = cos(lambda);
senlambda = sin(lambda);

% Desplazamientos en dirección radial, sur y este
Sr = -0.033*sen2theta*(m1*coslambda + m2*senlambda);
Ss = -0.009*cos2theta*(m1*coslambda + m2*senlambda);
Se =  0.009*costheta*(m1*senlambda - m2*coslambda);

% Rotación al marco ECEF
ds = [Ss;Se;Sr];
R = [	costheta*coslambda,	costheta*senlambda,	-sentheta	; ...
		-senlambda,			coslambda,			0			; ...
		sentheta*coslambda,	sentheta*senlambda,	costheta];

dr = R.'*ds;

end