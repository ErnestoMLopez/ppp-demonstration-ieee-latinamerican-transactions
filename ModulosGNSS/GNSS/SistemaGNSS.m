% Clase para los sistemas GNSS

classdef SistemaGNSS < uint32
	enumeration
		UNKNOWN_GNSS (0)
		GPS (1)
		GLONASS (2)
		Galileo (3)
		BeiDou (4)
		IRNSS (5)
		QZSS (6)
		SBAS (7)
   end
end