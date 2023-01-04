function [navSolPT] = resolverPosicionMinCuad(ps,pr,solPuntPT)
%RESOLVERPOSICIONMINCUAD Resoluci�n de las ecuaciones de GPS linealizaci�n
% Resuelve la posici�n y el sesgo de reloj de receptor a partir de las
% ecuaciones de GPS mediante linealizaci�n y minimos cuadrados,
% utilizando mediciones de pseudorangos solamente
% 
% ARGUMENTOS:
%	ps (JJx3) - Matriz con las posiciones de los sat�lites de la constelaci�n 
%				GPS visibles en el instante de observaci�n
%	pr (JJx1) - Vector con los pseudorangos de los sat�lites vistos, previamente
%				corregidos por reloj de sat�lite, correcci�n relativista, 
%				ion�sfera, etc.
%	solPT [4,1] - Soluci�n puntual previa de posici�n y velocidad

JJ = length(pr);

% Vector de mediciones
y = pr;

% Vectores l�nea de visi�n
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