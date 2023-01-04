function qinv = cuaternionInverso(q)
%CUATERNIONINVERSO Calcula el cuaternión inverso
% El cuaternión inverso representa una rotación en el sentido contrario a la del
% cuaternión original. Se asume que el cuaternión se encuentra en formato:
% 
%	q = [q0 qi qj qk]	->	qinv = [q0 -qi -qj -qk]/(q0^2+qi^2+qj^2+qk^2)
% 
% ARGUMENTOS:
%	q		- Cuaternión a invertir
%
% DEVOLUCIÓN:
%	qinv	- Cuaternión inverso

qinv = [q(1) -q(2:4)]./sum(q.^2);

return;