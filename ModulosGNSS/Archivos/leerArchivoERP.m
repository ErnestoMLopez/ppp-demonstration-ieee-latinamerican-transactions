function [datosERP] = leerArchivoERP(archivoerp)
%LEERARCHIVOERP Lee un archivo de parámetros de rotación de la Tierra
% Devuelve una tabla con los datos de un archivo ERP, producto obtenido a
% través del IGS en forma de productos final, rapid o ultra-rapid.
%
% PARAMETROS:
%	archivoerp  - Nombre del archivo ERP.
%
% DEVOLUCION:
%	datosERP	- Matriz con los datos extraidos. Cada fila corresponde a
%				un día particular, y las columnas están dadas por el 
%				estándar utilizado por la fuente:
%				(https://lists.igs.org/pipermail/igsmail/1998/003315.html)
%	
%   MJD      Xpole   Ypole  UT1-UTC    LOD  Xsig  Ysig   UTsig  LODsig  Nr Nf Nt    Xrt    Yrt  Xrtsig  Yrtsig
%              (10**-6")       (0.1 usec)    (10**-6")     (0.1 usec)              (10**-6"/d)    (10**-6"/d)
%


% Apertura del archivo
if (exist(archivoerp,'file') == 2)
    fid = fopen(archivoerp,'r');
else
   error(sprintf('No se pudo hallar el archivo: %s',archivoerp), 'ERROR!');
end

datosERP.Producto = 'ERP';
datosERP.data = zeros(0,19);
fin_datos = 0;


tline = fgetl(fid);
while isempty(strfind(tline,'MJD')) && ~feof(fid)
	tline = fgetl(fid);
end

tline = fgetl(fid);

while fin_datos == 0
	
	% Asigno memoria en principio para datos de una semana
	erpActual = zeros(7,19);
	
	ii = 1;
	while ii <= 7
				
		% Si se terminaron los datos salgo del while y armo la matriz final
		if ~isempty(strfind(tline,'END OBSERVED')) || feof(fid)
			fin_datos = 1;
			break;
		end
		
		tline = fgetl(fid);
		
		% Leo los datos de la época, si hay menos relleno con ceros
		datos = sscanf(tline,'%f');
		datos = [datos; zeros(19 - length(datos),1)];
		
		erpActual(ii,:) = datos';
		
		ii = ii + 1;
	end
	
	datosERP.data = [datosERP.data; erpActual(1:ii-1,:)];

end

fclose(fid);

end
