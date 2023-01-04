% Clase para los diferentes tipos de productos

classdef TipoProducto < uint32
	enumeration
		UNKNOWN_PROD	(0)
		RNX_OBS			(1)
		RNX_NAV			(2)
		SP3				(3)
		CLK				(4)
		ATX				(5)
	end
end