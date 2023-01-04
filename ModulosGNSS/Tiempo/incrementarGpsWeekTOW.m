function [tF_Week,tF_TOW] = incrementarGpsWeekTOW(tI_Week,tI_TOW,dt)
%INCREMENTARGPSWEEKTOW Incremento/decremento de tiempo GPS expresado en Week-TOW
%	
% ARGUMENTOS:
%	tI_Week	- Semana GPS inicial
%	tI_TOW	- Tiempo de la semana GPS inicial [s]
%	dt		- Paso de tiempo a incrementar o decrementar si es negativo [s]
% 
% DEVOLUCIÓN:
%	tF_Week	- Semana GPS final
%	tF_TOW	- Tiempo de la semana GPS final [s]
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 16/07/2021

SECONDS_IN_WEEK = 7*24*60*60;

tF_TOW = tI_TOW + dt;
tF_Week = tI_Week;

while tF_TOW > SECONDS_IN_WEEK
	tF_TOW = tF_TOW - SECONDS_IN_WEEK;
	tF_Week = tF_Week + 1;
end

while tF_TOW < 0
	tF_TOW = tF_TOW + SECONDS_IN_WEEK;
	tF_Week = tF_Week - 1;
end


end

