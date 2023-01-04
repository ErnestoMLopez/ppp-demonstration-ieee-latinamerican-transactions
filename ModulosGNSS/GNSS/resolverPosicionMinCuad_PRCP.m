function [navSolPT] = resolverPosicionMinCuad_PRCP(ps,pr,cp,solPuntPT)
%RESOLVERPOSICIONMINCUAD_PRCP Resoluci�n de las ecuaciones de GPS linealizaci�n
% Resuelve la posici�n y el sesgo de reloj de receptor a partir de las
% ecuaciones de GPS mediante linealizaci�n y minimos cuadrados, utilizando 
% mediciones de pseudorangos y de fases de portadora. 
% 
% ARGUMENTOS:
%	ps (JJx3) - Matriz con las posiciones de los sat�lites de la
%				constelaci�n Gps visibles en el instante de observaci�n
%	pr (JJx1) - Vector con los pseudorangos de los sat�lites vistos, previamente
%				corregidos por reloj de sat�lite, correcci�n relativista, 
%				ion�sfera, etc.
%	cp (JJx1) - Vector con las mediciones de fase de los sat�lites vistos,	
%				previamente corregidos por reloj de sat�lite, correcci�n 
%				relativista, ion�sfera, etc
%	solPT (4x1) - Soluci�n puntual previa de posici�n y velocidad

sigma_PR = 1;
sigma_CP = 0.005;

JJ = length(pr);

% Vector de mediciones
y = [pr; cp];

% Vectores l�nea de visi�n
e = ps - repmat(solPuntPT(1:3)',JJ,1);

e_unit = zeros(JJ,3);
pr_est = zeros(JJ,1);

for jj = 1:JJ
	norma_e = norm(e(jj,:));
	e_unit(jj,:) = e(jj,:)./norma_e;
	pr_est(jj) = norma_e + solPuntPT(4);
end

y_est = [pr_est; pr_est];

delta_y = y - y_est;

H = [-e_unit,	ones(JJ,1),		zeros(JJ); ...
	 -e_unit,	ones(JJ,1),		eye(JJ)];
 
Qy = blkdiag(sigma_PR^2*eye(JJ),sigma_CP^2*eye(JJ));

W = inv(Qy);

delta_x = (H'*W*H)\(H'*W*delta_y);

navSolPT = solPuntPT + delta_x(1:4);

end