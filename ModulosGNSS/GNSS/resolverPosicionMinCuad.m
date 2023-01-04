function [navSolPT] = resolverPosicionMinCuad(ps,pr,solPuntPT)
%RESOLVERPOSICIONMINCUAD Resolución de las ecuaciones de GPS linealización
% Resuelve la posición y el sesgo de reloj de receptor a partir de las
% ecuaciones de GPS mediante linealización y minimos cuadrados,
% utilizando mediciones de pseudorangos solamente
% 
% ARGUMENTOS:
%	ps (JJx3) - Matriz con las posiciones de los satélites de la constelación 
%				GPS visibles en el instante de observación
%	pr (JJx1) - Vector con los pseudorangos de los satélites vistos, previamente
%				corregidos por reloj de satélite, corrección relativista, 
%				ionósfera, etc.
%	solPT [4,1] - Solución puntual previa de posición y velocidad

JJ = length(pr);

% Vector de mediciones
y = pr;

% Vectores línea de visión
e = ps - repmat(solPuntPT(1:3)',JJ,1);

e_unit = zeros(JJ,3);
pr_est = zeros(JJ,1);

for jj = 1:JJ
	norma_e = norm(e(jj,:));
	e_unit(jj,:) = e(jj,:)./norma_e;
	pr_est(jj) = norma_e + solPuntPT(4);
end

y_est = pr_est;

delta_y = y - y_est;

H = [-e_unit,	ones(JJ,1)];
 
delta_x = (H'*H)\(H'*delta_y);

navSolPT = solPuntPT + delta_x(1:4);

end