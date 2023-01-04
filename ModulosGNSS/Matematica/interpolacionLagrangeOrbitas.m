function [ps,vs] = interpolacionLagrangeOrbitas(t,tn,xn,yn,zn)
%INTERPOLACIONLAGRANGEORBITAS Interpolaci�n por polinomio de Lagrange de �rbitas
% Obtiene las coordenadas de posici�n y velocidad de un sat�lite a partir de la
% interpolaci�n por polinomio de Lagrange de hasta 4 puntos de datos de �rbitas 
% precisas.
%
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posici�n.
%	tn			- �pocas de los datos de �rbitas precisas
%	xn			- Coordenadas X de posici�n en las �pocas dadas
%	yn			- Coordenadas Y de posici�n en las �pocas dadas
%	zn			- Coordenadas Z de posici�n en las �pocas dadas
%
% DEVOLUCI�N:
%	ps (3x1) -	Posici�n en el marco ECEF para el tiempo GPS dado [m]
%	vs (3x1) -	Velocidad en el marco ECEF para el tiempo GPS dado [m/s]

NN = length(tn);

L = ones(NN,1);
Lp = zeros(NN,1);
psx = 0; psy = 0; psz = 0;
vsx = 0; vsy = 0; vsz = 0;

for ii = 1:NN
	
	for jj = 1:NN
	
		if jj ~= ii
			
			L(ii) = L(ii).*(t-tn(jj))/(tn(ii)-tn(jj));
			lp = 1;
			
			for kk = 1:NN
								
				if (kk ~= ii) && (kk ~= jj)
					
					lp = lp.*(t-tn(kk))/(tn(ii)-tn(kk));
				
				end
				
			end
			
			Lp(ii) = Lp(ii) + lp*(1/(tn(ii)-tn(jj)));
			
		end
		
	end
	
	psx = psx + xn(ii)*L(ii);
	psy = psy + yn(ii)*L(ii);
	psz = psz + zn(ii)*L(ii);

	vsx = vsx + xn(ii)*Lp(ii);
	vsy = vsy + yn(ii)*Lp(ii);
	vsz = vsz + zn(ii)*Lp(ii);
	
end

ps = [psx; psy; psz];
vs = [vsx; vsy; vsz];

end