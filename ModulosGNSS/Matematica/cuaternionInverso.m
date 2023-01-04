function qinv = cuaternionInverso(q)
%CUATERNIONINVERSO Calcula el cuaterni�n inverso
% El cuaterni�n inverso representa una rotaci�n en el sentido contrario a la del
% cuaterni�n original. Se asume que el cuaterni�n se encuentra en formato:
% 
%	q = [q0 qi qj qk]	->	qinv = [q0 -qi -qj -qk]/(q0^2+qi^2+qj^2+qk^2)
% 
% ARGUMENTOS:
%	q		- Cuaterni�n a invertir
%
% DEVOLUCI�N:
%	qinv	- Cuaterni�n inverso

qinv = [q(1) -q(2:4)]./sum(q.^2);

return;