% Clase para las diferentes clases de mediciones

classdef ClaseMedicion < uint32
	enumeration
		UNKNOWN_CLASSMED	(0)
		COMBINACION			(1)
		PSEUDORANGO			(2)
		FASE_PORTADORA		(3)
		DOPPLER				(4)
		CN0					(5)
		RETARDO_IONOSFERICO	(6)
		CANAL_RECEPTOR		(7)
	end
end