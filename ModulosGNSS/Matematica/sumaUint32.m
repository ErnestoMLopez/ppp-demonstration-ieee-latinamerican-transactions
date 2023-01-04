function C = sumaUint32(A,B)
%SUMAUINT32 Suma de tipo de datos uint32 con overflow
%   Dado que Matlab por defecto no provoca overflow en las variables de tipo de
%   datos enteros sino que saturan al valor máximo, esta función implementa una
%   suma como sería en C.


if (A > 0) && (B > (intmax('uint32')-A))		% Caso overflow
	
	C = B - (intmax('uint32')-A) - 1;
	
else
	
	C = A + B;
	
end

end
