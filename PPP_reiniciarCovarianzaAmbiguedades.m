function Pk = PPP_reiniciarCovarianzaAmbiguedades(Pk,configPPP)
%PPP_REINICIARCOVARIANZAAMBIGUEDADES Resetea entradas de la matriz de covarianza
% Cambia las entradas de la diagonal de la matriz de covarianza del error de
% estimación correspondientes a las ambigüedades a su valor inicial. Esto es 
% útil por ej. en el caso de un cambio en los productos utilizados durante el
% procesamiento cuasi tiempo real, para que un cambio en los sesgos de reloj de
% satélite no se traduzca en un cambio abrupto en la solución de posición y
% pueda ser absorbido por un reajuste de las ambigüedades
% 
% ARGUMENTOS:
%	Pk			- Matriz de covarianza del error de estimación en una época dada
%	configPPP	- Estrucutura con parámetros de configuración establecidos por
%				el usuario
% 
% DEVOLUCIÓN:
%	Pk			- Matriz de covarianza del error de estimación con las
%				ambigüedades reiniciadas

NN = size(Pk,1);

% En PPP 5 son los estados fijos, es decir que no hay ambigüedades
if NN == 5
	return;
end

for nn = 6:NN
	Pk(nn,nn) = configPPP.SIGMA_APRIORI_B^2;
end

end