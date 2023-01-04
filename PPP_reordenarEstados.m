function [xkk_prior,Pkk_prior] = PPP_reordenarEstados(datosSatelites,datosSatelitesPrevios,xkk_prior,Pkk_prior,configPPP)
%PPP_REORDENARESTADOS Reordena los estados de ambigüedades según satélites en vista
% A partir de los satélites seguidos previamente y los actuales determina si es
% necesario borrar un estado de ambigüedad y su entrada en la matriz de
% covarianza o si hay que agregar un estado más. En este último caso inicializa
% la ambigüedad en base a las mediciones de pseudorango y de fase de portadora
% que estén disponibles.
% 
% ARGUMENTOS:
%	datosSatelites (JJx1)	- Arreglo de estructuras de Satelites presentes en la época
%	datosSatelitesPrevios	- Arreglo de estructuras de Satelites presentes en 
%							la época anterior
%	xkk_prior ((5+NAMBprev)x1)				- Vector estado de la época anterior
%	Pkk_prior ((5+NAMBprev)x(5+NAMBprev))	- Matriz de covarianza de la época anterior
%	configPPP				- Estrucutura con parámetros de configuración 
%							establecidos por el usuario.
% 
% DEVOLUCIÓN:
%	xkk_prior ((5+NAMB)x1)			- Vector estado reordenado
%	Pkk_prior ((5+NAMB)x(5+NAMB))	- Matriz de covarianza reordenada


% Cantidad de satélites detectados
JJ = length(datosSatelites);
JJprev = length(datosSatelitesPrevios);


% Indice de las ambigüedades que tenía y voy a recorrer
namb = 1;


%----- Busqueda de satélites perdidos (ambigüedades perdidas en realidad) ------
for jjprev = 1:JJprev
	
	NNprev = length(datosSatelitesPrevios(jjprev).Mediciones);
	
	for nnprev = 1:NNprev

		% Si la medición no es deseada para posicionamiento, o no es una fase de
		% portadora, o no era utilizada antes, o el satélite no era utilizado
		% antes, entonces sigo con la siguiente
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelitesPrevios(jjprev).Mediciones(nnprev).Tipo);
		flag_es_fase = datosSatelitesPrevios(jjprev).Mediciones(nnprev).Clase == ClaseMedicion.FASE_PORTADORA;
		flag_sat_usable = datosSatelitesPrevios(jjprev).Usable;
		flag_med_usable = datosSatelitesPrevios(jjprev).Mediciones(nnprev).Usable;
		
		if ~flag_es_medicion || ~flag_es_fase || ~flag_sat_usable || ~flag_med_usable
			continue;
		end
		
		
		% Busco si el satélite está presente y usable en la época actual
		jj = find(	([datosSatelites.PRN] == datosSatelitesPrevios(jjprev).PRN) & ...
					([datosSatelites.GNSS] == datosSatelitesPrevios(jjprev).GNSS) & ...
					([datosSatelites.Usable] == datosSatelitesPrevios(jjprev).Usable));
		
		% Si el satélite ya no está o la medición no está utilizable entonces borro
		% la ambigüedad del estado y de la matriz
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

%----- Busqueda de satélites nuevos (para inicializar ambigüedades) ------------
for jj = 1:JJ
	
	NN = length(datosSatelites(jj).Mediciones);
	
	for nn = 1:NN
		
		% Si la medición no es deseada para posicionamiento, o no es una fase de
		% portadora, o no es válida para utilizarse, o el satélite no es válido
		% para utilizarse, entonces sigo con la siguiente
		flag_es_medicion = any(configPPP.MEDICIONES == datosSatelites(jj).Mediciones(nn).Tipo);
		flag_es_fase = datosSatelites(jj).Mediciones(nn).Clase == ClaseMedicion.FASE_PORTADORA;
		flag_sat_usable = datosSatelites(jj).Usable;
		flag_med_usable = datosSatelites(jj).Mediciones(nn).Usable;
		
		if ~flag_es_medicion || ~flag_es_fase || ~flag_sat_usable || ~flag_med_usable
			continue;
		end
		
		
		% Esta es una medición válida con ambigüedad, subo el índice
		namb = namb + 1;
		
		% Busco si el satélite estaba presente y usable en la época previa
		jjprev = find(	([datosSatelitesPrevios.PRN] == datosSatelites(jj).PRN) & ...
						([datosSatelitesPrevios.GNSS] == datosSatelites(jj).GNSS) & ...
						([datosSatelitesPrevios.Usable] == datosSatelites(jj).Usable));
					
		% Si el satélite no estaba o la medición no estaba utilizable entonces 
		% agrego e inicializo el estado de la ambigüedad y sus entradas en la 
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

% Número de estados que tenía previamente
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

% Por ahora no inicializo ambigüedades, solo pongo un 0
Bjj0 = 0;

% Inserto la ambigüedad en el estado
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



