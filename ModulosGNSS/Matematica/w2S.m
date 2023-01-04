function S = w2S(w)
%w2S Representacion matricial del producto vectorial
%   Convierte un vector con el cual se desea multiplicar vectorialmente a
%   otro a una matriz equivalente S

S = [0 -w(3) w(2);...
	w(3) 0 -w(1);...
    -w(2) w(1) 0]; 

end
