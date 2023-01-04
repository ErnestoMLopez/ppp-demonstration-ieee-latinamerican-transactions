function [ps,vs] = interpolacionLagrangeOrbitas(t,tn,xn,yn,zn)
%INTERPOLACIONLAGRANGEORBITAS Interpolación por polinomio de Lagrange de órbitas
% Obtiene las coordenadas de posición y velocidad de un satélite a partir de la
% interpolación por polinomio de Lagrange de hasta 4 puntos de datos de órbitas 
% precisas.
%
% ARGUMENTOS:
%	t			- Tiempo GPS para el que se quiere calcular la posición.
%	tn			- Épocas de los datos de órbitas precisas
%	xn			- Coordenadas X de posición en las épocas dadas
%	yn			- Coordenadas Y de posición en las épocas dadas
%	zn			- Coordenadas Z de posición en las épocas dadas
%
% DEVOLUCIÓN:
%	ps (3x1) -	Posición en el marco ECEF para el tiempo GPS dado [m]
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