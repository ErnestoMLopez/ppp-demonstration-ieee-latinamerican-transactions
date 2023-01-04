% Clase para las diferentes clases de productos

classdef ClaseProducto < uint32
	enumeration
		UNKNOWN_CLASSPROD	(0)
		RNX_NAV				(1)
		IGS					(2)
		IGR					(3)
		IGU					(4)
		IGC					(5)
	end
end