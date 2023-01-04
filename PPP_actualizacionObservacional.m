function [xk_post,Pk_post,datosSatelites] = PPP_actualizacionObservacional(datosSatelites,xk_prior,Pk_prior,configPPP)
%PPP_ACTUALIZACIONOBSERVACIONAL Realiza la actualizaci�n por mediciones del KF
% En base a los sat�lites ya detectados y modelados, y las ambig�edades
% estimadas en la �poca anterior realiza la actualizaci�n observacional del
% filtro. Una vez hecha se guardan los nuevos estados de ambig�edades 
% 
% ARGUMENTOS:
%	datosSatelites (JJx1)	- Arreglo de estructuras para los datos de los
%							sat�lites presentes en la �poca actual.
%	xk_prior ((5+NAMB)x1)	- Vector estado a-priori de la soluci�n
%	Pk_prior ((5+NAMB)x(5+NAMB))- Matriz de covarianza a-priori de la soluci�n
%	configPPP				- Estrucutura con par�metros de configuraci�n 
%							establecidos por el usuario.
% 
% DEVOLUCI�N:
%	datosSatelites (JJx1)	- Arreglo de estructuras para los datos de los
%							sat�lites presentes en la �poca actual con las
%							ambig�edades actualizadas.
%	xk_post ((5+NAMB)x1)	- Vector estado a-posteriori de la soluci�n
%	Pk_post ((5+NAMB)x(5+NAMB))- Matriz de covarianza a-posteriori de la soluci�n


% Cantidad de sat�lites detectados
JJ = length(datosSatelites);

% N�mero de estados
NEST = length(xk_prior);


%-------------------------------------------------------------------------------
% Primero hago una pasada por los datos de todos los sat�lites para sacar
% cantidades de mediciones y de ambig�edades que va a haber
NMED = 0;
NAMB = 0;
for jj = 1:JJ
	NN = length(datosSatelites(jj).Mediciones);
	for nn = 1:NN
		flag_sat_usable = datosSatelites(jj).Usable;
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		
		if flag_sat_usable && flag_med_usable && flag_es_medicion
			NMED = NMED + 1;
			if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
				NAMB = NAMB + 1;
			end
		end		
	end
end
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Inicializo vectores y matrices
zk = zeros(NMED,1);			% Vector de mediciones
zk_est = zeros(NMED,1);		% Vector de estimados de mediciones
Rk = zeros(NMED);			% Matriz de covarianza de mediciones
Hk = zeros(NMED,5+NAMB);	% Matriz de sensitividad
%-------------------------------------------------------------------------------


nmed = 0;
namb = 0;

%-------------------------------------------------------------------------------
% Voy buscando las mediciones
for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);
	
	for nn = 1:NN
		
		flag_sat_usable = datosSatelites(jj).Usable;
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		
		if flag_sat_usable && flag_med_usable && flag_es_medicion
			nmed = nmed + 1;
			
			if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
				namb = namb + 1;
			end
			
			% Busco la medici�n propiamente dicha
			zk(nmed) = datosSatelites(jj).Mediciones(nn).Valor;
			
			% Busco el valor estimado de la medicion
			zk_est(nmed) = datosSatelites(jj).Mediciones(nn).ValorEstimado;
			
			if datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA
				Hk(nmed,5+namb) = 1;
				Rk(nmed,nmed) = configPPP.SIGMA_CP^2;
			else
				Rk(nmed,nmed) = configPPP.SIGMA_PR^2;
			end
			
			Hk(nmed,1:3) = -(datosSatelites(jj).LdV)';
			Hk(nmed,4) = 1;
			Hk(nmed,5) = datosSatelites(jj).Mediciones(nn).MapeoZTD;
			
		end
		
	end
	
end
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Matriz de ganancia de Kalman
Kk = Pk_prior*Hk.'/(Hk*Pk_prior*Hk.' + Rk);

% Actualizaci�n de estado y de matriz de covarianza del error
dxk = Kk*(zk - zk_est);
xk_post = xk_prior + dxk;
Pk_post = (eye(NEST) - Kk*Hk)*Pk_prior*(eye(NEST) - Kk*Hk).' + Kk*Rk*Kk.';

% Calculo los estimados postfit de la medici�n con la soluci�n obtenida
zk_est_post = zk_est + Hk*dxk;
%-------------------------------------------------------------------------------


%-------------------------------------------------------------------------------
% Guardo los datos actualizados de las ambig�edades
namb = 0;
nmed = 0;
for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);
	
	for nn = 1:NN
		
		flag_sat_usable = datosSatelites(jj).Usable;
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
				
		if flag_sat_usable && flag_med_usable && flag_es_medicion
			nmed = nmed + 1;
			
			datosSatelites(jj).Mediciones(nn).ValorEstimadoPost = zk_est_post(nmed);
			
			flag_es_fase = datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA;
			
			if flag_es_fase
				namb = namb + 1;
				
				datosSatelites(jj).Mediciones(nn).Ambig = xk_post(5+namb);
			end
		end
	end
end
%-------------------------------------------------------------------------------

end

