function [handle] = skyplot(azimut,elevacion,titulo)
%SKYPLOT Grafico skyplot de una constelaci�n de sat�lites
%	Esta funcion asume que azimut y elevacion son matrices de las mismas
%	dimensiones, donde las filas corresponden a cada �poca a graficar y las
%	columnas corresponden a cada sat�lite. Para la constelaci�n GPS ser�an
%	matrices de KKx32.
% 
%	Los sat�lites fuera de vista deben ser enmascarados antes y sus 
%	entradas igualadas a NaN.
%
%	Ambos �ngulos se asumen en GRADOS.


JJ = size(azimut,2);

handle = figure;

for jj = 1:JJ
	polarplot(deg2rad(azimut(:,jj)),90 - elevacion(:,jj),'LineWidth',1); hold on;
end

ax = gca;
ax.ThetaZeroLocation = 'top';
ax.ThetaDir = 'clockwise';
ax.ThetaTickLabel = {'0� N','30�','60�','90� E','120�','150�','180� S','210�','240�','270� W','300�','330�'};
ax.RTick = [0 20 40 60 80 90];
ax.RTickLabel = {'90�','70�','50�','30�','10�','0�'};
title(titulo)

end