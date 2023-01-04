function rinexNav = generarEstructuraEfemerides(GNSS)
%GENERARESTRUCTURAEFEMERIDES Definición de la estructura con todos los campos
%necesarios para contener un conjunto de efemérides

if GNSS == SistemaGNSS.GPS
	rinexNav = struct( ...
	...% Efemérides
	'GNSS',			SistemaGNSS.GPS, ...
	'PRN',			0, ...
	'ttom',			0, ...
	'GPS_WEEK',		0, ...
	'IODC',			0, ...
	'toc',			0, ...
	'af0',			0, ...
	'af1',			0, ...
	'af2',			0, ...
	'IODE',			0, ...	
	'toe',			0, ...
	'Delta_n',		0, ...
	'M0',			0, ...
	'e',			0, ...
	'sqrt_a',		0, ...
	'OMEGA0',		0, ...
	'i0',			0, ...
	'omega',		0, ...
	'OMEGA_DOT',	0, ...
	'i_DOT',		0, ...
	'Cic',			0, ...	
	'Cis',			0, ...
	'Crc',			0, ...
	'Crs',			0, ...	
	'Cuc',			0, ...
	'Cus',			0, ...	
	'L2_Codes',		0, ...
	'L2_PDataFlag',	0, ...
	'Accuracy',		0, ...
	'Health',		0, ...
	'TGD',			0, ...
	'FitInterval',	0  ...
	);
else
	error('GNSS no soportado aún');
end

end


%{
 +----------------------------------------------------------------------------+
 |	BASADO EN EL FORMATO RINEX 2.11											  |
 +----------------------------------------------------------------------------+
 |                                   TABLE A3                                 |
 |         GPS NAVIGATION MESSAGE FILE - HEADER SECTION DESCRIPTION           |
 +--------------------+------------------------------------------+------------+
 |    HEADER LABEL    |               DESCRIPTION                |   FORMAT   |
 |  (Columns 61-80)   |                                          |            |
 +--------------------+------------------------------------------+------------+
 |RINEX VERSION / TYPE| - Format version (2.11)                  | F9.2,11X,  |
 |                    | - File type ('N' for Navigation data)    |   A1,19X   |
 +--------------------+------------------------------------------+------------+
 |PGM / RUN BY / DATE | - Name of program creating current file  |     A20,   |
 |                    | - Name of agency  creating current file  |     A20,   |
 |                    | - Date of file creation                  |     A20    |
 +--------------------+------------------------------------------+------------+
*|COMMENT             | Comment line(s)                          |     A60    |*
 +--------------------+------------------------------------------+------------+
*|ION ALPHA           | Ionosphere parameters A0-A3 of almanac   |  2X,4D12.4 |*
 |                    | (page 18 of subframe 4)                  |            |
 +--------------------+------------------------------------------+------------+
*|ION BETA            | Ionosphere parameters B0-B3 of almanac   |  2X,4D12.4 |*
 +--------------------+------------------------------------------+------------+
*|DELTA-UTC: A0,A1,T,W| Almanac parameters to compute time in UTC| 3X,2D19.12,|*
 |                    | (page 18 of subframe 4)                  |     2I9    |
 |                    | A0,A1: terms of polynomial               |            |
 |                    | T    : reference time for UTC data       |      *)    |
 |                    | W    : UTC reference week number.        |            |
 |                    |        Continuous number, not mod(1024)! |            |
 +--------------------+------------------------------------------+------------+
*|LEAP SECONDS        | Delta time due to leap seconds           |     I6     |*
 +--------------------+------------------------------------------+------------+
 |END OF HEADER       | Last record in the header section.       |    60X     |
 +--------------------+------------------------------------------+------------+

                        Records marked with * are optional


 +----------------------------------------------------------------------------+
 |                                  TABLE A4                                  |
 |           GPS NAVIGATION MESSAGE FILE - DATA RECORD DESCRIPTION            |
 +--------------------+------------------------------------------+------------+
 |    OBS. RECORD     | DESCRIPTION                              |   FORMAT   |
 +--------------------+------------------------------------------+------------+
 |PRN / EPOCH / SV CLK| - Satellite PRN number                   |     I2,    |
 |                    | - Epoch: Toc - Time of Clock             |            |
 |                    |          year (2 digits, padded with 0   |            |
 |                    |                if necessary)             |  1X,I2.2,  |
 |                    |          month                           |   1X,I2,   |
 |                    |          day                             |   1X,I2,   |
 |                    |          hour                            |   1X,I2,   |
 |                    |          minute                          |   1X,I2,   |
 |                    |          second                          |    F5.1,   |
 |                    | - SV clock bias       (seconds)          |  3D19.12   |
 |                    | - SV clock drift      (sec/sec)          |            |
 |                    | - SV clock drift rate (sec/sec2)         |     *)     |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 1| - IODE Issue of Data, Ephemeris          | 3X,4D19.12 |
 |                    | - Crs                 (meters)           |            |
 |                    | - Delta n             (radians/sec)      |            |
 |                    | - M0                  (radians)          |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 2| - Cuc                 (radians)          | 3X,4D19.12 |
 |                    | - e Eccentricity                         |            |
 |                    | - Cus                 (radians)          |            |
 |                    | - sqrt(A)             (sqrt(m))          |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 3| - Toe Time of Ephemeris                  | 3X,4D19.12 |
 |                    |                       (sec of GPS week)  |            |
 |                    | - Cic                 (radians)          |            |
 |                    | - OMEGA               (radians)          |            |
 |                    | - CIS                 (radians)          |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 4| - i0                  (radians)          | 3X,4D19.12 |
 |                    | - Crc                 (meters)           |            |
 |                    | - omega               (radians)          |            |
 |                    | - OMEGA DOT           (radians/sec)      |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 5| - IDOT                (radians/sec)      | 3X,4D19.12 |
 |                    | - Codes on L2 channel                    |            |
 |                    | - GPS Week # (to go with TOE)            |            |
 |                    |   Continuous number, not mod(1024)!      |            |
 |                    | - L2 P data flag                         |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 6| - SV accuracy         (meters)           | 3X,4D19.12 |
 |                    | - SV health        (bits 17-22 w 3 sf 1) |            |
 |                    | - TGD                 (seconds)          |            |
 |                    | - IODC Issue of Data, Clock              |            |
 +--------------------+------------------------------------------+------------+
 | BROADCAST ORBIT - 7| - Transmission time of message       **) | 3X,4D19.12 |
 |                    |         (sec of GPS week, derived e.g.   |            |
 |                    |    from Z-count in Hand Over Word (HOW)  |            |
 |                    | - Fit interval        (hours)            |            |
 |                    |         (see ICD-GPS-200, 20.3.4.4)      |            |
 |                    |   Zero if not known                      |            |
 |                    | - spare                                  |            |
 |                    | - spare                                  |            |
 +--------------------+------------------------------------------+------------+
%}
