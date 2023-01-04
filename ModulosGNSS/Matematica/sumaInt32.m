function C = sumaInt32(A,B)
%SUMAINT32 Suma de tipo de datos int32 con overflow y underflow
%   Dado que Matlab por defecto no provoca overflow ni underflow en las 
%	variables de tipo de datos enteros sino que saturan al valor máximo o 
%	mínimo, esta función implementa una suma como sería en C.


if (A > 0) && (B > (intmax('int32')-A))		% Caso overflow
	
	C = intmin('int32') + B - (intmax('int32')-A) - 1;
	
elseif (A < 0) && (B < (intmin('int32')-A))	% Caso underflow
	
	C = intmax('int32') + B - (intmin('int32')-A-1);
	
else
	
	C = A + B;
	
end

end