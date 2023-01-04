function [xkk_prior,Pkk_prior] = PPP_actualizacionTemporal(xk_post,Pk_post,Qk,configPPP)

% Cantidad de ambig�edades
NAMB = length(xk_post) - 5;


% Las coordenadas de posici�n se deber�an propagar seg�n se haya configurado un 
% modelo cinem�tico o est�tico. Por ahora las mantengo iguales para no perder la
% �ltima estimaci�n de posici�n de receptor. El caso cinem�tico se considera
% mediante el agregado de ruido
Phir = eye(3);
	
% El sesgo de reloj de receptor es tratado como un proceso de Wiener, por lo que
% se mantiene constante
Phicdtr = 1;

% La correcci�n del ZTD h�medo se propaga por modelo de proceso Gauss-Markov
F = exp(-configPPP.T/configPPP.TAU_DZTD);
PhiDZTDw = F;

% Las ambig�edades se mantienen constantes, as� que propago solo los primeros 5
% estados
Phik = blkdiag(Phir,Phicdtr,PhiDZTDw,eye(NAMB));
xkk_prior = Phik*xk_post;


% Propago la matriz de covarianza del error de estimaci�n
Gk = [eye(5); zeros(NAMB,5)];
Pkk_prior = Phik*Pk_post*Phik' + Gk*Qk*Gk';


end