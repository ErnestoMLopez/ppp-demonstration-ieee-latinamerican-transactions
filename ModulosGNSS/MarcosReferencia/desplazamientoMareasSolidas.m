function [dr] = desplazamientoMareasSolidas(t,r)
%DESPLAZAMIENTOMAREASSOLIDAS Desplazamiento de sitio por mareas sólidas terrestres
%   A partir de la posición a priori de un receptor en una estación terrestre en
%	una época dada calcula el desplazamiento del sitio debido a las mareas
%	sólidas terrestres. Basado en [IERS Conventions, 2010] y [Springer Handbook 
% 	of GNSS]
% 
% ARGUMENTOS:
%	t			- Tiempo GPS [s]
% 	r (3x1)		- Vector posición de una estación en el marco ECEF [m]
% 	
% DEVOLUCION:
%	dr (3x1)	- Desplazamiento debido a las mareas sólidas terrestres en
%				el marco ECEF [m] 	

global RE MUE MUSOL MULUNA


h2_0 = 0.6070;		% Número de Love nominal de grado 2
l2_0 = 0.0847;		% Número de Shida nominal de grado 2
h3 = 0.292;			% Número de Love nominal de grado 3
l3 = 0.015;			% Número de Shida nominal de grado 3

x = r(1);
y = r(2);
z = r(3);
rr = norm(r);
r_unit = r./rr;

% Convierto la época al JD
jd = gpsTime2utcJd(t);

% Calculo las posiciones del Sol y la Luna en ECEF
rS = posicionSolEcef(jd);
rL = posicionLunaEcef(jd);
rrS = norm(rS);
rrL = norm(rL);
rS_unit = rS./rrS;
rL_unit = rL./rrL;

%-------------------------------------------------------------------------------
% Desplazamiento en el dominio del tiempo: en fase grado 2 y 3 
%-------------------------------------------------------------------------------

% Calculo el coseno de la latitud geocéntrica
cosphi = sqrt(x^2+y^2)/rr;

% Aplico correcciones a los números de Love y de Shida
h2 = h2_0 - 0.0006*(1 - 3/2*cosphi^2);
l2 = l2_0 + 0.0002*(1 - 3/2*cosphi^2);

% Producto punto de los vectores unitarios
rS_r = rS_unit'*r_unit;
rL_r = rL_unit'*r_unit;

% Términos en dirección radial
dr2_S = 3*rS_r^2*(h2/2-l2) - h2/2;
dr2_L = 3*rL_r^2*(h2/2-l2) - h2/2;
dr3_S = 5/2*(h3-3*l3)*rS_r^3 + 3/2*(l3-h3)*rS_r;
dr3_L = 5/2*(h3-3*l3)*rL_r^3 + 3/2*(l3-h3)*rL_r;

% Términos en dirección al Sol y la Luna
drS2 = 3*l2*rS_r;
drL2 = 3*l2*rL_r;
drS3 = 3/2*l3*(5*rS_r^2-1);
drL3 = 3/2*l3*(5*rL_r^2-1);

% Factores de escala
F2S = (MUSOL/MUE)*RE*(RE/rrS)^3;
F2L = (MULUNA/MUE)*RE*(RE/rrL)^3;
F3S = (MUSOL/MUE)*RE*(RE/rrS)^4;
F3L = (MULUNA/MUE)*RE*(RE/rrL)^4;

% Desplazamiento 
dr_T =	F2S*(dr2_S*r_unit + drS2*rS_unit) + ...
		F2L*(dr2_L*r_unit + drL2*rL_unit) + ...
		F3S*(dr3_S*r_unit + drS3*rS_unit) + ...
		F3L*(dr3_L*r_unit + drL3*rL_unit);

%-------------------------------------------------------------------------------
% Desplazamiento en el dominio de la frecuencia: en fase diurna componente K1
%-------------------------------------------------------------------------------

% Calculo el seno de la latitud geocéntrica y la longitud
sinphi = z/rr;
lambda = rad2deg(atan2(y,x));

% Calculo el tiempo sidereo medio de Greenwich
GMST = jd2gmst(jd);

% Desplazamiento en la dirección radial solamente (vertical)
dr_F = -0.0253*sinphi*cosphi*sind(GMST+lambda)*r_unit;

%-------------------------------------------------------------------------------


% Suma de las componentes

dr = dr_T + dr_F;

end

