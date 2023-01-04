function [datosEOP] = leerArchivoEOP(archivoeop)
%LEERARCHIVOEOP Lee un archivo de parámetros de orientación de la Tierra
%   Devuelve una tabla con los datos de un archivo de texto de EOPs,
%   obtenido de http://celestrak.com/, misma fuente que los usados por el
%   STK.
%
%	PARAMETROS:
%	archivoeop -	Nombre del archivo de EOPs.
%
%	DEVOLUCION:
%	eopData -		Matriz con los datos extraidos. Cada fila corresponde a
%					un día particular, y las columnas están dadas por el 
%					estándar utilizado por la fuente:
%	
% ----------------------------------------------------------------------------------------------------
%   Date    MJD      x         y       UT1-UTC      LOD       dPsi    dEpsilon     dX        dY    DAT
% (0h UTC)           "         "          s          s          "        "          "         "     s 
% ----------------------------------------------------------------------------------------------------
% yyyy mm dd nnnnn +n.nnnnnn +n.nnnnnn +n.nnnnnnn +n.nnnnnnn +n.nnnnnn +n.nnnnnn +n.nnnnnn +n.nnnnnn nnn
% ----------------------------------------------------------------------------------------------------
%


%%

% Apertura del archivo
if (exist(archivoeop,'file') == 2)
    fid = fopen(archivoeop,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivoeop), 'ERROR!');
end

datos = zeros(0, 13);
fin_datos = 0;


tline = fgetl(fid);
while isempty(strfind(tline,'BEGIN OBSERVED')) && ~feof(fid)
	tline = fgetl(fid);
end


while fin_datos == 0
	
	% Asigno memoria en principio para datos de un año entero
	eopActual = zeros(365, 13);
	
	ii = 1;
	while ii <= 365
		tline = fgetl(fid);
		
		% Si se terminaron los datos salgo del while y armo la matriz final
		if ~isempty(strfind(tline,'END OBSERVED')) || feof(fid)
			fin_datos = 1;
			break;
		end
		
		eopActual(ii,1) = str2double(tline(1:4));
		eopActual(ii,2) = str2double(tline(6:7));
		eopActual(ii,3) = str2double(tline(9:10));
		eopActual(ii,4) = str2double(tline(12:16));
		eopActual(ii,5) = str2double(tline(18:26));
		eopActual(ii,6) = str2double(tline(28:36));
		eopActual(ii,7) = str2double(tline(38:47));
		eopActual(ii,8) = str2double(tline(49:58));
		eopActual(ii,9) = str2double(tline(60:68));
		eopActual(ii,10) = str2double(tline(70:78));
		eopActual(ii,11) = str2double(tline(80:88));
		eopActual(ii,12) = str2double(tline(90:98));
		eopActual(ii,13) = str2double(tline(100:102));
		
		ii = ii + 1;
	end
	
	datos = [datos; eopActual(1:ii-1,:)];

end

datosEOP.data = datos;
datosEOP.Producto = 'EOP';

fclose(fid);

end
