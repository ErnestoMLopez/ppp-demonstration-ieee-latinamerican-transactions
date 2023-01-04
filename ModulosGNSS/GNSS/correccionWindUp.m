function [corrWindUp] = correccionWindUp(t,r,rj,O_B2F,corrWindUpprev)
%CORRECCIONWINDUP C�lculo de la correcci�n wind-up para fases de portadora
% Calcula la correcci�n por el efecto wind-up acumulado sobre las mediciones de 
% fase de portadora. Esta correcci�n es dependiente de la frecuencia, por lo que
% en el modelo de mediciones debe ser multiplicada por la longitud de onda 
% correspondiente.
% Basado en el algoritmo dado en [Sanz, Zornoza, Pajares, 2013]
% 
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n.
%	r (3x1)		- Posici�n ECEF a-priori del receptor [m]
%	rj (3x1)	- Posici�n ECEF del sat�lite [m]
%	O_B2F (3x3) - Matriz de orientaci�n del receptor. Corresponde a la 
%				matriz de transformaci�n de un vector en el marco de referencia
%				local del receptor (sea cual sea) al marco ECEF.
%	corrWindUpprev	- Correcci�n wind-up acumulada de la �poca previa [ciclos]
% 
% DEVOLUCI�N:
%	corrWindUp	- Modelo de correcci�n wind-up acumulado [ciclos]


% Para obtener la correcci�n debo definir los vectores a y b en el plano de la
% antena receptora. Para una estaci�n terrestre fija estos corresponder�an a los
% vectores unitarios este y norte expresados en ECEF. En un caso general, donde
% la antena receptora puede estar orientada de forma diferente al ENU estos
% vectores corresponden a las dos primeras columnas de la matriz de orientaci�n
% entre el marco del cuerpo y el ECEF
a = O_B2F(:,1);
b = O_B2F(:,2);

% Para los vectores unitarios en direcciones perpendiculares a la l�nea de
% visi�n uso el mismo marco de referencia y procedimiento que para la correcci�n
% APC de los sat�lites:
% Obtengo la posici�n del Sol en la �poca
jd = gpsTime2utcJd(t);
rS = posicionSolEcef(jd);

% Armo los versores del marco de referencia del sat�lite
k = -rj./norm(rj);
e = (rS - rj)./norm(rS - rj);
j = cross(k,e)./norm(cross(k,e));
i = cross(j,k)./norm(cross(j,k));

ap = i;
bp = j;

% Vector l�nea de visi�n inverso unitario
rho = (r - rj)./norm(r - rj);

d = a - dot(rho,a).*rho + cross(rho,b);
dp = ap - dot(rho,ap).*rho - cross(rho,bp);

zeta = dot(rho,cross(dp,d));

dphi = sign(zeta)*acos(dot(dp,d)/(norm(d)*norm(dp)));
DPhiprev = corrWindUpprev*2*pi;

% Si la correcci�n previa era 0 (caso de primera epoca del sat�lite en vista)
% ajusto el N de forma tal de arrancar siempre en el rango [-0.5;0.5] [ciclos].
% Si no hiciera esto, parte del efecto wind-up de dicho sat�lite ir�a a parar a
% la ambig�edad entera
if DPhiprev == 0
	N = round(-dphi/(2*pi));
else
	N = round((DPhiprev - dphi)/(2*pi));
end

corrWindUp = dphi/(2*pi) + N;

end

