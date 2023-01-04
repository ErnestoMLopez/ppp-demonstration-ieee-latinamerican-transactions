function [handle] = skyplot(azimut,elevacion,titulo)
%SKYPLOT Grafico skyplot de una constelación de satélites
%	Esta funcion asume que azimut y elevacion son matrices de las mismas
%	dimensiones, donde las filas corresponden a cada época a graficar y las
%	columnas corresponden a cada satélite. Para la constelación GPS serían
%	matrices de KKx32.
% 
%	Los satélites fuera de vista deben ser enmascarados antes y sus 
%	entradas igualadas a NaN.
%
%	Ambos ángulos se asumen en GRADOS.


JJ = size(azimut,2);

handle = figure;

for jj = 1:JJ
	polarplot(deg2rad(azimut(:,jj)),90 - elevacion(:,jj),'LineWidth',1); hold on;
end

ax = gca;
ax.ThetaZeroLocation = 'top';
ax.ThetaDir = 'clockwise';
ax.ThetaTickLabel = {'0º N','30º','60º','90º E','120º','150º','180º S','210º','240º','270º W','300º','330º'};
ax.RTick = [0 20 40 60 80 90];
ax.RTickLabel = {'90º','70º','50º','30º','10º','0º'};
title(titulo)

end