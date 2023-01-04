function Pk = PPP_reiniciarCovarianzaAmbiguedades(Pk,configPPP)
%PPP_REINICIARCOVARIANZAAMBIGUEDADES Resetea entradas de la matriz de covarianza
% Cambia las entradas de la diagonal de la matriz de covarianza del error de
% estimaci�n correspondientes a las ambig�edades a su valor inicial. Esto es 
% �til por ej. en el caso de un cambio en los productos utilizados durante el
% procesamiento cuasi tiempo real, para que un cambio en los sesgos de reloj de
% sat�lite no se traduzca en un cambio abrupto en la soluci�n de posici�n y
% pueda ser absorbido por un reajuste de las ambig�edades
% 
% ARGUMENTOS:
%	Pk			- Matriz de covarianza del error de estimaci�n en una �poca dada
%	configPPP	- Estrucutura con par�metros de configuraci�n establecidos por
%				el usuario
% 
% DEVOLUCI�N:
%	Pk			- Matriz de covarianza del error de estimaci�n con las
%				ambig�edades reiniciadas

NN = size(Pk,1);

% En PPP 5 son los estados fijos, es decir que no hay ambig�edades
if NN == 5
	return;
end

for nn = 6:NN
	Pk(nn,nn) = configPPP.SIGMA_APRIORI_B^2;
end

end