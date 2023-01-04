function [xkk_prior,Pkk_prior] = PPP_reordenarEstados(datosSatelites,datosSatelitesPrevios,xkk_prior,Pkk_prior,configPPP)
%PPP_REORDENARESTADOS Reordena los estados de ambig�edades seg�n sat�lites en vista
% A partir de los sat�lites seguidos previamente y los actuales determina si es
% necesario borrar un estado de ambig�edad y su entrada en la matriz de
% covarianza o si hay que agregar un estado m�s. En este �ltimo caso inicializa
% la ambig�edad en base a las mediciones de pseudorango y de fase de portadora
% que est�n disponibles.
% 
% ARGUMENTOS:
%	datosSatelites (JJx1)	- Arreglo de estructuras de Satelites presentes en la �poca
%	datosSatelitesPrevios	- Arreglo de estructuras de Satelites presentes en 
%							la �poca anterior
%	xkk_prior ((5+NAMBprev)x1)				- Vector estado de la �poca anterior
%	Pkk_prior ((5+NAMBprev)x(5+NAMBprev))	- Matriz de covarianza de la �poca anterior
%	configPPP				- Estrucutura con par�metros de configuraci�n 
%							establecidos por el usuario.
% 
% DEVOLUCI�N:
%	xkk_prior ((5+NAMB)x1)			- Vector estado reordenado
%	Pkk_prior ((5+NAMB)x(5+NAMB))	- Matriz de covarianza reordenada


% Cantidad de sat�lites detectados
JJ = length(datosSatelites);
JJprev = length(datosSatelitesPrevios);


% Indice de las ambig�edades que ten�a y voy a recorrer
namb = 1;


%----- Busqueda de sat�lites perdidos (ambig�edades perdidas en realidad) ------
for jjprev = 1:JJprev
	
	NNprev = length(datosSatelitesPrevios(jjprev).Mediciones);
	
	for nnprev = 1:NNprev

		% Si la medici�n no es deseada para posicionamiento, o no es una fase de
		% portadora, o no era utilizada antes, o el sat�lite no era utilizado
		% antes, entonces sigo con la siguiente
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelitesPrevios(jjprev).Mediciones(nnprev).Tipo);
		flag_es_fase = datosSatelitesPrevios(jjprev).Mediciones(nnprev).Clase == ClaseMedicion.FASE_PORTADORA;
		flag_sat_usable = datosSatelitesPrevios(jjprev).Usable;
		flag_med_usable = datosSatelitesPrevios(jjprev).Mediciones(nnprev).Usable;
		
		if ~flag_es_medicion || ~flag_es_fase || ~flag_sat_usable || ~flag_med_usable
			continue;
		end
		
		
		% Busco si el sat�lite est� presente y usable en la �poca actual
		jj = find(	([datosSatelites.PRN] == datosSatelitesPrevios(jjprev).PRN) & ...
					([datosSatelites.GNSS] == datosSatelitesPrevios(jjprev).GNSS) & ...
					([datosSatelites.Usable] == datosSatelitesPrevios(jjprev).Usable));
		
		% Si el sat�lite ya no est� o la medici�n no est� utilizable entonces borro
		% la ambig�edad del estado y de la matriz
		if isempty(jj)
			[xkk_prior,Pkk_prior] = borrarAmbiguedad(namb,xkk_prior,Pkk_prior);
		elseif ~(datosSatelites(jj).Mediciones(nnprev).Usable) || ~(datosSatelites(jj).Usable)
			[xkk_prior,Pkk_prior] = borrarAmbiguedad(namb,xkk_prior,Pkk_prior);
		else
			namb = namb + 1;
		end
		
	end
end
%-------------------------------------------------------------------------------




namb = 0;

%----- Busqueda de sat�lites nuevos (para inicializar ambig�edades) ------------
for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);
	
	for nn = 1:NN
		
		% Si la medici�n no es deseada para posicionamiento, o no es una fase de
		% portadora, o no es v�lida para utilizarse, o el sat�lite no es v�lido
		% para utilizarse, entonces sigo con la siguiente
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		flag_es_fase = datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA;
		flag_sat_usable = datosSatelites(jj).Usable;
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		
		if ~flag_es_medicion || ~flag_es_fase || ~flag_sat_usable || ~flag_med_usable
			continue;
		end
		
		
		% Esta es una medici�n v�lida con ambig�edad, subo el �ndice
		namb = namb + 1;
		
		% Busco si el sat�lite estaba presente y usable en la �poca previa
		jjprev = find(	([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN) & ...
						([datosSatelitesPrevios.GNSS] == datosSatelites(jj).GNSS) & ...
						([datosSatelitesPrevios.Usable] == datosSatelites(jj).Usable));
					
		% Si el sat�lite no estaba o la medici�n no estaba utilizable entonces 
		% agrego e inicializo el estado de la ambig�edad y sus entradas en la 
		% matriz de covarianza
		if isempty(jjprev)
			[xkk_prior,Pkk_prior] = inicializarAmbiguedad(namb,nn,xkk_prior,Pkk_prior,datosSatelites(jj),configPPP);
		elseif ~(datosSatelitesPrevios(jjprev).Mediciones(nn).Usable) || ~(datosSatelitesPrevios(jjprev).Usable)
			[xkk_prior,Pkk_prior] = inicializarAmbiguedad(namb,nn,xkk_prior,Pkk_prior,datosSatelites(jj),configPPP);
		end
					
	end

end

end



%-------------------------------------------------------------------------------
function [xkk_prior,Pkk_prior] = borrarAmbiguedad(namb,xkk_prior,Pkk_prior)

xkk_prior(5+namb) = [];
Pkk_prior(5+namb,:) = [];
Pkk_prior(:,5+namb) = [];

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function [xkk_prior,Pkk_prior] = inicializarAmbiguedad(namb,nn,xkk_prior,Pkk_prior,datosSatelite,configPPP)

% N�mero de estados que ten�a previamente
nx = length(xkk_prior);

% % Cantidad de mediciones disponibles
% NN = length(datosSatelite.Mediciones);
% 
% 
% PR = [];
% CP = datosSatelite.Mediciones(nn).Valor;
% 
% for nn = 1:NN
% 	if datosSatelite.Mediciones(nn).Clase == ClaseMedicion.PSEUDORANGO
% 		PR = datosSatelite.Mediciones(nn).Valor;
% 	end
% end
% 
% if ~isempty(PR) && ~isempty(CP)
% 	Bjj0 = CP - PR;
% else
% 	Bjj0 = 0;
% end

% Por ahora no inicializo ambig�edades, solo pongo un 0
Bjj0 = 0;

% Inserto la ambig�edad en el estado
xkk_prior = [xkk_prior(1:5+namb-1); ...
			Bjj0; ...
			xkk_prior(5+namb:end)];


% Inserto una fila en la matriz de covarianza
Pkk_prior = [Pkk_prior(1:5+namb-1,:); ...
			zeros(1,nx); ...
			Pkk_prior(5+namb:end,:)];

% Inserto una columna en la matriz de covarianza
Pkk_prior = [Pkk_prior(:,1:5+namb-1), ...
			zeros(nx+1,1), ...
			Pkk_prior(:,5+namb:end)];

% En la diagonal inicializo la varianza
Pkk_prior(5+namb,5+namb) = configPPP.SIGMA_APRIORI_B^2;


end
%-------------------------------------------------------------------------------



