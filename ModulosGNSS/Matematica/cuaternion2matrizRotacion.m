function R = cuaternion2matrizRotacion(q)
%CUATERNION2MATRIZROTACION Convierte un cuaterni�n a la matriz de rotaci�n equivalente
%   Calcula la matriz de rotaci�n (MCD) de un cuaterni�n en formato:
% 
%		q = [q0 qi qj qk]
% 
% ARGUMENTOS:
%	q	- Cuaterni�n a convertir
% 
% DEVOLUCI�N:
%	R	- MCD equivalente al cuaterni�n

q = q./sum(q.^2);

R = zeros(3);

R(1,1) = q(1).^2 + q(2).^2 - q(3).^2 - q(4).^2;
R(1,2) = 2.*(q(2).*q(3) + q(1).*q(4));
R(1,3) = 2.*(q(2).*q(4) - q(1).*q(3));
R(2,1) = 2.*(q(2).*q(3) - q(1).*q(4));
R(2,2) = q(1).^2 - q(2).^2 + q(3).^2 - q(4).^2;
R(2,3) = 2.*(q(3).*q(4) + q(1).*q(2));
R(3,1) = 2.*(q(2).*q(4) + q(1).*q(3));
R(3,2) = 2.*(q(3).*q(4) - q(1).*q(2));
R(3,3) = q(1).^2 - q(2).^2 - q(3).^2 + q(4).^2;

end