function [xkk_prior,Pkk_prior] = PPP_actualizacionTemporal(xk_post,Pk_post,Qk,configPPP)

% Cantidad de ambigüedades
NAMB = length(xk_post) - 5;


% Las coordenadas de posición se deberían propagar según se haya configurado un 
% modelo cinemático o estático. Por ahora las mantengo iguales para no perder la
% última estimación de posición de receptor. El caso cinemático se considera
% mediante el agregado de ruido
Phir = eye(3);
	
% El sesgo de reloj de receptor es tratado como un proceso de Wiener, por lo que
% se mantiene constante
Phicdtr = 1;

% La corrección del ZTD húmedo se propaga por modelo de proceso Gauss-Markov
F = exp(-configPPP.T/configPPP.TAU_DZTD);
PhiDZTDw = F;

% Las ambigüedades se mantienen constantes, así que propago solo los primeros 5
% estados
Phik = blkdiag(Phir,Phicdtr,PhiDZTDw,eye(NAMB));
xkk_prior = Phik*xk_post;


% Propago la matriz de covarianza del error de estimación
Gk = [eye(5); zeros(NAMB,5)];
Pkk_prior = Phik*Pk_post*Phik' + Gk*Qk*Gk';


end