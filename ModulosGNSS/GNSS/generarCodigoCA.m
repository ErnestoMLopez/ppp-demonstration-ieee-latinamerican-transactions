function CA = generarCodigoCA(PRN)
%GENERARCODIGOCA Generador de la secuencia completa del código C/A de GPS
% 
% ARGUMENTOS:
%	PRN -PRN del satélite del cual se quiere generar el código
% 
% DEVOLUCIÓN:
%	CA (1023x1) - Arreglo de 0s y 1s del código C/A

CA = zeros(1023,1);

% Combinacion de taps del registro G2
[G2Tap1,G2Tap2] = obtenerConfiguracionG2DeSateliteGps(PRN);

G1 = ones(1,10);
G2 = ones(1,10);

for j = 1 : 1023
	g1 = G1(10);
	g2 = xor(G2(G2Tap1),G2(G2Tap2));
	CA(j) = xor(g1,g2); % Secuencia Gold: XOR de los codigos G1 y G2.
	
	% x1 y y1 son las realimentaciones a los bloques de G1 y G2
	x1 = xor(G1(3),G1(10));
	y1 = xor(xor(xor(xor(xor(G2(2),G2(3)),G2(6)),G2(8)),G2(9)),G2(10));
	
	% Corrimiento de los bits una posicion en los bloques G1 y G2.
	% El bit que estaba en la posicion 10 se pierde.
	for i = 10 : -1 : 2
		G1(i) = G1(i - 1);
		G2(i) = G2(i - 1);
	end
	
	G1(1) = x1;
	G2(1) = y1;
end

end
