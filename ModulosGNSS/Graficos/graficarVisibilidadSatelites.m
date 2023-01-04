function handle = graficarVisibilidadSatelites(tR,Visibles,Referencia)
%GRAFICARVISIBLIDADSATELITES Gráfico de los satélites visibles de un GNSS
% 
% ARGUMENTOS:
%	tR (KKx1)			- Tiempo GPS de cada época [s]
%	Visibles (KKxSS)	- Matriz de booleanos, cada fila corresponde a una época 
%						y SS es la cantidad total de satélites dependiente del 
%						GNSS usado. Se indica con un 1 los visibles
%	Referencia (KKxSS)	- Matriz de booleanos opcional, cada fila corresponde a 
%						una época y SS es la cantidad total de satélites 
%						dependiente del GNSS usado. Se indica con un único 1 por
%						época el satélite referencia usado para armar dobles
%						diferencias.
% 
% 
% AUTOR: Ernesto Mauro López
% FECHA: 17/05/2019

ColoresR2014 = [0		0.4470	0.7410; ...
				0.8500	0.3250	0.0980; ...
				0.9290	0.6940	0.1250; ...
				0.4940	0.1840	0.5560; ...
				0.4660	0.6740	0.1880; ...
				0.3010	0.7450	0.9330; ...
				0.6350	0.0780	0.1840];
			
[KK,SS] = size(Visibles);

CantidadVisibles = sum(Visibles,2);

Visibles = double(Visibles);
Visibles(Visibles == 0) = NaN;

for ss = 1:SS
	Visibles(:,ss) = ss.*Visibles(:,ss);
end

tiempos = (tR - tR(1))./3600;

handle = figure; subplot(3,1,[1,2]); hold on;

for ss = 1:SS
	plot(tiempos,Visibles(:,ss),'o-','Color',ColoresR2014(1,:),'MarkerFaceColor',ColoresR2014(1,:),'MarkerSize',5);
end

axis([0 tiempos(end) 0 SS+1]); box on; grid on;
yticks(1:SS)
a = get(gca,'YTickLabel');  
set(gca,'YTickLabel',a,'FontSize',9)
title('Satélites visibles','Fontsize',13);

if ~isempty(Referencia)
	
	Referencia = double(Referencia);
	Referencia(Referencia == 0) = NaN;
	
	for ss = 1:SS
		Referencia(:,ss) = ss.*Referencia(:,ss);
	end
	
	for ss = 1:SS
		plot(tiempos,Referencia(:,ss),'o-','Color',ColoresR2014(2,:),'MarkerFaceColor',ColoresR2014(2,:),'MarkerSize',6);
	end	
	
end

subplot(3,1,3); hold off;

plot(tiempos,CantidadVisibles); axis tight; grid on; set(gca, 'Fontsize',13);
xlabel('Tiempo [h]','Interpreter','latex');

end