function [corrWindUp] = correccionWindUp(t,r,rj,O_B2F,corrWindUpprev)
%CORRECCIONWINDUP Cálculo de la corrección wind-up para fases de portadora
% Calcula la corrección por el efecto wind-up acumulado sobre las mediciones de 
% fase de portadora. Esta corrección es dependiente de la frecuencia, por lo que
% en el modelo de mediciones debe ser multiplicada por la longitud de onda 
% correspondiente.
% Basado en el algoritmo dado en [Sanz, Zornoza, Pajares, 2013]
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición.
%	r (3x1)		- Posición ECEF a-priori del receptor [m]
%	rj (3x1)	- Posición ECEF del satélite [m]
%	O_B2F (3x3) - Matriz de orientación del receptor. Corresponde a la 
%				matriz de transformación de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	corrWindUpprev	- Corrección wind-up acumulada de la época previa [ciclos]
% 
% DEVOLUCIÓN:
%	corrWindUp	- Modelo de corrección wind-up acumulado [ciclos]


% Para obtener la corrección debo definir los vectores a y b en el plano de la
% antena receptora. Para una estación terrestre fija estos corresponderían a los
% vectores unitarios este y norte expresados en ECEF. En un caso general, donde
% la antena receptora puede estar orientada de forma diferente al ENU estos
% vectores corresponden a las dos primeras columnas de la matriz de orientación
% entre el marco del cuerpo y el ECEF
a = O_B2F(:,1);
b = O_B2F(:,2);

% Para los vectores unitarios en direcciones perpendiculares a la línea de
% visión uso el mismo marco de referencia y procedimiento que para la corrección
% APC de los satélites:
% Obtengo la posición del Sol en la época
jd = gpsTime2utcJd(t);
rS = posicionSolEcef(jd);

% Armo los versores del marco de referencia del satélite
k = -rj./norm(rj);
e = (rS - rj)./norm(rS - rj);
j = cross(k,e)./norm(cross(k,e));
i = cross(j,k)./norm(cross(j,k));

ap = i;
bp = j;

% Vector línea de visión inverso unitario
rho = (r - rj)./norm(r - rj);

d = a - dot(rho,a).*rho + cross(rho,b);
dp = ap - dot(rho,ap).*rho - cross(rho,bp);

zeta = dot(rho,cross(dp,d));

dphi = sign(zeta)*acos(dot(dp,d)/(norm(d)*norm(dp)));
DPhiprev = corrWindUpprev*2*pi;

% Si la corrección previa era 0 (caso de primera epoca del satélite en vista)
% ajusto el N de forma tal de arrancar siempre en el rango [-0.5;0.5] [ciclos].
% Si no hiciera esto, parte del efecto wind-up de dicho satélite iría a parar a
% la ambigüedad entera
if DPhiprev == 0
	N = round(-dphi/(2*pi));
else
	N = round((DPhiprev - dphi)/(2*pi));
end

corrWindUp = dphi/(2*pi) + N;

end

