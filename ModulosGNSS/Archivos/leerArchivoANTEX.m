function [satAnt,recAnt] = leerArchivoANTEX(archivoantex)
%LEERARCHIVOANTEX Extrae datos de un archivo ANTEX
%   Devuelve un arreglo de estructuras con todos los datos de todos los
%   satélites y otra con todas las antenas contenidas en el archivo ANTEX.

%	ARGUMENTOS:
%	archivoantex -	Nombre del archivo de datos ANTEX
%
%	DEVOLUCION:
%		satAnt (JJx1) - Arreglo de estructuras con los datos de las antenas de 
%						cada satélite de cada constelación presente en el 
%						archivo ANTEX (ver generarEstructuraSateliteANTEX()).
%		recAnt (MMx1) - Arreglo de estructuras con los datos de las antenas de 
%						receptor calibradas en las estaciones IGS (ver 
%						generarEstructuraAntenaANTEX())
%		

% Inicialización
satAnt = [];
recAnt = [];

% Abro el archivo
if (exist(archivoantex,'file') == 2)
    fid = fopen(archivoantex,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivoantex), 'ERROR!');
end


% Salteo el encabezado
tline = fgetl(fid);
while isempty(strfind(tline,'END OF HEADER')) && ~feof(fid)
	tline = fgetl(fid);
end



% Empiezo a leer línea por línea hasta el fin del archivo
tline = fgetl(fid);

while ~feof(fid)
	
	if ~isempty(strfind(tline,'START OF ANTENNA'))
	elseif ~isempty(strfind(tline,'TYPE / SERIAL NO'))
		PRN = str2double(tline(22:23));
		SYS = tline(21);
		
		% Determino si se trata de un satélite o un receptor
		if (PRN ~= 0) && (SYS == 'G' || SYS == 'R' || SYS == 'E' || SYS == 'C' || SYS == 'I' || SYS == 'J' || SYS == 'S' || SYS == 'M')

			leyendoSatORec = 0;
			SatAntex = generarEstructuraSateliteANTEX();
			
			SatAntex.GNSS = determinarSistemaGNSS(SYS);
			SatAntex.PRN = PRN;
			SatAntex.SVN = str2double(tline(42:44));
			SatAntex.Block = determinarSateliteBlock(tline(1:20));
		else
			
			leyendoSatORec = 1;
			AntAntex = generarEstructuraAntenaANTEX();
			
			AntAntex.Antena = strtrim(tline(1:15));
			AntAntex.Domo = strtrim(tline(17:20));
			
		end
		
	elseif ~isempty(strfind(tline,'VALID'))
		t_YYYY = str2double(tline(3:6));
		t_MM = str2double(tline(11:12));
		t_DD = str2double(tline(17:18));
		t_hh = str2double(tline(23:24));
		t_mm = str2double(tline(29:30));
		t_ss = str2double(tline(34:43));
		
		% Convierto a formato GPS
		tV = ymdhms2gpsTime(t_YYYY,t_MM,t_DD,t_hh,t_mm,t_ss);
		
		if ~isempty(strfind(tline,'FROM'))
			SatAntex.tValidFrom = tV;
		elseif ~isempty(strfind(tline,'UNTIL'))
			SatAntex.tValidUntil = tV;
		end
		
	elseif ~isempty(strfind(tline,'DAZI'))
		
		if leyendoSatORec == 0
			SatAntex.DAZI = str2double(tline(3:8));
			if SatAntex.DAZI > 0
				SatAntex.NAZI = 360/SatAntex.DAZI + 1;
			end
		elseif leyendoSatORec == 1
			AntAntex.DAZI = str2double(tline(3:8));
			if AntAntex.DAZI > 0
				AntAntex.NAZI = 360/AntAntex.DAZI + 1;
			end
		end
		
	elseif ~isempty(strfind(tline,'ZEN1 / ZEN2 / DZEN'))
		
		if leyendoSatORec == 0
			SatAntex.ZEN1 = str2double(tline(3:8));
			SatAntex.ZEN2 = str2double(tline(9:14));
			SatAntex.DZEN = str2double(tline(15:20));
			SatAntex.NZEN = (SatAntex.ZEN2-SatAntex.ZEN1)/SatAntex.DZEN + 1;
		elseif leyendoSatORec == 1
			AntAntex.ZEN1 = str2double(tline(3:8));
			AntAntex.ZEN2 = str2double(tline(9:14));
			AntAntex.DZEN = str2double(tline(15:20));
			AntAntex.NZEN = (AntAntex.ZEN2-AntAntex.ZEN1)/AntAntex.DZEN + 1;
		end
		
	elseif ~isempty(strfind(tline,'START OF FREQUENCY'))
		
		frec_indx = str2double(tline(5:6));
		gnss_indx = determinarSistemaGNSS(tline(4));
		
	elseif ~isempty(strfind(tline,'NORTH / EAST / UP'))
		
		if leyendoSatORec == 0
			SatAntex.APC(frec_indx,gnss_indx,:) = [ str2double(tline(1:10)); ...
													str2double(tline(11:20)); ...
													str2double(tline(21:30))]./1000;
		elseif leyendoSatORec == 1
			AntAntex.APC(frec_indx,gnss_indx,:) = [ str2double(tline(1:10)); ...
													str2double(tline(11:20)); ...
													str2double(tline(21:30))]./1000;
		end
												
		% Sigo leyendo PCV no-azimutales
		tline = fgetl(fid);
		if tline ~= -1
			if strcmp(tline(4:8),'NOAZI')
				if leyendoSatORec == 0
					for ii = 1:SatAntex.NZEN
						taux = tline(9+8*(ii-1):9+8*(ii-1)+7);
						SatAntex.PCVZEN(frec_indx,gnss_indx,ii) = str2double(taux)./1000;
					end
				elseif leyendoSatORec == 1
					for ii = 1:AntAntex.NZEN
						taux = tline(9+8*(ii-1):9+8*(ii-1)+7);
						AntAntex.PCVZEN(frec_indx,gnss_indx,ii) = str2double(taux)./1000;
					end
				end
			end
		end
			
		% Si hay correcciones azimutales las leo
		if leyendoSatORec == 0 && SatAntex.DAZI > 0
			for ii = 1:SatAntex.NAZI
				tline = fgetl(fid);
				for jj = 1:SatAntex.NZEN
					taux = tline(9+8*(jj-1):9+8*(jj-1)+7);
					SatAntex.PCVAZI(frec_indx,gnss_indx,ii,jj) = str2double(taux)./1000;
				end
			end
		elseif leyendoSatORec == 1 && AntAntex.DAZI > 0
			for ii = 1:AntAntex.NAZI
				tline = fgetl(fid);
				for jj = 1:AntAntex.NZEN
					taux = tline(9+8*(jj-1):9+8*(jj-1)+7);
					AntAntex.PCVAZI(frec_indx,gnss_indx,ii,jj) = str2double(taux)./1000;
				end
			end
		end
		
	elseif ~isempty(strfind(tline,'END OF ANTENNA'))
		
		% Concateno la estructura del elemento pasado
		if leyendoSatORec == 0
			satAnt = [satAnt; SatAntex];
		elseif leyendoSatORec == 1
			recAnt = [recAnt; AntAntex];
		end
		
	end
	
	tline = fgetl(fid);
	
end

fclose(fid);

end




%-------------------------------------------------------------------------------
function GNSS = determinarSistemaGNSS(SYS)
	
if SYS == 'G' || SYS == ' '
	GNSS = SistemaGNSS.GPS;
	return;
elseif SYS == 'R'
	GNSS = SistemaGNSS.GLONASS;
	return;
elseif SYS == 'E'
	GNSS = SistemaGNSS.Galileo;
	return;
elseif SYS == 'C'
	GNSS = SistemaGNSS.BeiDou;
	return;
elseif SYS == 'J'
	GNSS = SistemaGNSS.QZSS;
	return;
elseif SYS == 'I'
	GNSS = SistemaGNSS.IRNSS;
	return;	
elseif SYS == 'S'
	GNSS = SistemaGNSS.SBAS;
	return;	
else
	GNSS = SistemaGNSS.UNKNOWN_GNSS;
	return;
end

end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
function GNSS = determinarSateliteBlock(blockstr)
%{
Nomenclatura tomada del IGS, archivo 
https://files.igs.org/pub/station/general/rcvr_ant.tab
(columna de la derecha aproximadamente tomada como etiqueta)

+----------------------+-------------------------------------------------------+
| Satellite Antennae   |                                                       |
| IGS Codes-20 columns |                      Description                      |
| XXXXXXXXXXXXXXXXXXXX |                                                       |
+----------------------+-------------------------------------------------------+
| BEIDOU-2G            |  BeiDou-2 GEO                                         |
| BEIDOU-2I            |  BeiDou-2 IGSO                                        |
| BEIDOU-2M            |  BeiDou-2 MEO                                         |
| BEIDOU-3I            |  BeiDou-3 IGSO                                        |
| BEIDOU-3SI-CAST      |  BeiDou-3 experimental IGSO (manufactured by CAST)    |
| BEIDOU-3SI-SECM      |  BeiDou-3 experimental IGSO (manufactured by SECM)    |
| BEIDOU-3SM-CAST      |  BeiDou-3 experimental MEO (manufactured by CAST)     |
| BEIDOU-3SM-SECM      |  BeiDou-3 experimental MEO (manufactured by SECM)     |
| BEIDOU-3M-CAST       |  BeiDou-3 MEO (manufactured by CAST)                  |
| BEIDOU-3M-SECM       |  BeiDou-3 MEO (manufactured by SECM)                  |
| BEIDOU-3G-CAST       |  BeiDou-3 GEO (manufactured by CAST)                  |
| BLOCK I              |  GPS Block I     : SVN 01-11                          |
| BLOCK II             |  GPS Block II    : SVN 13-21                          |
| BLOCK IIA            |  GPS Block IIA   : SVN 22-40                          |
| BLOCK IIR-A          |  GPS Block IIR   : SVN 41, 43-46, 51, 54, 56          |
| BLOCK IIR-B          |  GPS Block IIR   : SVN 47, 59-61                      |
| BLOCK IIR-M          |  GPS Block IIR-M : SVN 48-50, 52-53, 55, 57-58        |
| BLOCK IIF            |  GPS Block IIF   : SVN 62-73                          |
| BLOCK IIIA           |  GPS Block IIIA  : SVN 74-81                          |
| GALILEO-0A           |  Galileo In-Orbit Validation Element A (GIOVE-A)      |
| GALILEO-0B           |  Galileo In-Orbit Validation Element B (GIOVE-B)      |
| GALILEO-1            |  Galileo IOV     : GSAT 0101-0104                     |
| GALILEO-2            |  Galileo FOC     : GSAT 0201-0222                     |
| GLONASS              |  GLONASS         : GLONASS no. 201-249, 750-798       |
| GLONASS-M            |  GLONASS-M       : GLONASS no. 701-749,               |
|                      |                    IGS SVN R850-R861 (GLO no. + 100)  |
| GLONASS-M+           |  GLONASS-M+                                           |
| GLONASS-K1           |  GLONASS-K1      : IGS SVN R801-R802 (GLO no. + 100)  |
| GLONASS-K2           |  GLONASS-K2                                           |
| IRNSS-1GEO           |  IRNSS-1 GEO                                          |
| IRNSS-1IGSO          |  IRNSS-1 IGSO                                         |
| QZSS                 |  QZSS Block I (Michibiki-1)                           |
| QZSS-2I              |  QZSS Block II IGSO (Michibiki-2,4)                   |
| QZSS-2G              |  QZSS Block II GEO (Michibiki-3)                      |
+----------------------+-------------------------------------------------------+
| Previously valid     |  New Codes                                            |
+----------------------+-------------------------------------------------------+
| BLOCK IIR            |  BLOCK IIR-A          | BLOCK IIR-B                   |
+----------------------+-------------------------------------------------------+
%}

% Elimino espacios en blanco al final
blockstr = strtrim(blockstr);

if strcmp(blockstr,'BLOCK I')
	GNSS = SateliteBlock.GPS_BLOCK_I;
	return;
elseif strcmp(blockstr,'BLOCK II')
	GNSS = SateliteBlock.GPS_BLOCK_II;
	return;
elseif strcmp(blockstr,'BLOCK IIA')
	GNSS = SateliteBlock.GPS_BLOCK_IIA;
	return;
elseif	strcmp(blockstr,'BLOCK IIR') || ...
		strcmp(blockstr,'BLOCK IIR-A') || ...
		strcmp(blockstr,'BLOCK IIR-B')
	GNSS = SateliteBlock.GPS_BLOCK_IIR;
	return;
elseif strcmp(blockstr,'BLOCK IIR-M')
	GNSS = SateliteBlock.GPS_BLOCK_IIR_M;
	return;
elseif strcmp(blockstr,'BLOCK IIF')
	GNSS = SateliteBlock.GPS_BLOCK_IIF;
	return;
elseif strcmp(blockstr,'BLOCK IIIA')
	GNSS = SateliteBlock.GPS_BLOCK_IIIA;
	return;
elseif strcmp(blockstr,'GLONASS')
	GNSS = SateliteBlock.GLONASS;
	return;
elseif strcmp(blockstr,'GLONASS-M')
	GNSS = SateliteBlock.GLONASS_M;
	return;
elseif strcmp(blockstr,'GLONASS-K1')
	GNSS = SateliteBlock.GLONASS_K1;
	return;
elseif strcmp(blockstr,'GLONASS-K2')
	GNSS = SateliteBlock.GLONASS_K2;
	return;
elseif	strcmp(blockstr,'GALILEO-0A') || ...
		strcmp(blockstr,'GALILEO-0B') || ...
		strcmp(blockstr,'GALILEO-1')
	GNSS = SateliteBlock.GALILEO_IOV;
	return;
elseif strcmp(blockstr,'GALILEO-2')
	GNSS = SateliteBlock.GALILEO_FOC;
	return;
elseif strcmp(blockstr,'BEIDOU-2G')
	GNSS = SateliteBlock.BEIDOU_2_GEO;
	return;
elseif strcmp(blockstr,'BEIDOU-2I')
	GNSS = SateliteBlock.BEIDOU_2_IGSO;
	return;
elseif strcmp(blockstr,'BEIDOU-2M')
	GNSS = SateliteBlock.BEIDOU_2_MEO;
	return;
elseif strcmp(blockstr,'BEIDOU-3I') || strcmp(blockstr,'BEIDOU-3SI-CAST') || strcmp(blockstr,'BEIDOU-3SI-SECM')
	GNSS = SateliteBlock.BEIDOU_3_IGSO;
	return;
elseif strcmp(blockstr,'BEIDOU-3SM-CAST') || strcmp(blockstr,'BEIDOU-3SM-SECM') || strcmp(blockstr,'BEIDOU-3M-CAST') || strcmp(blockstr,'BEIDOU-3M-SECM')
	GNSS = SateliteBlock.BEIDOU_3_MEO;
	return;
elseif strcmp(blockstr,'BEIDOU-3G-CAST')
	GNSS = SateliteBlock.BEIDOU_3_GEO;
	return;
elseif strcmp(blockstr,'IRNSS-1GEO')
	GNSS = SateliteBlock.IRNSS_1_GEO;
	return;
elseif strcmp(blockstr,'IRNSS-1IGSO')
	GNSS = SateliteBlock.IRNSS_1_IGSO;
	return;
elseif strcmp(blockstr,'QZSS')
	GNSS = SateliteBlock.QZSS_BLOCK_I;
	return;
elseif strcmp(blockstr,'QZSS-2I')
	GNSS = SateliteBlock.QZSS_BLOCK_II_IGSO;
	return;
elseif strcmp(blockstr,'QZSS-2G')
	GNSS = SateliteBlock.QZSS_BLOCK_II_GEO;
	return;
end	
	
end
%-------------------------------------------------------------------------------
