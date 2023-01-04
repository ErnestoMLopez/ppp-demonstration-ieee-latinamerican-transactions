function antexRec = verificarDatosAntenaReceptor(datosRecATX,antena,domo)
%VERIFICARDATOSANTENARECEPTOR Busca los datos de antena que corresponden
% Esta función verifica que la antena y domo utilizados tengan datos presentes
% en el archivo ANTEX leído previamente, y de ser así devuelve solo los datos de
% interés. En caso de encontrarse la antena pero no el domo se da la opción de
% utilizar los datos calibrados de la antena sin domo.
% 
% ARGUMENTOS:
%	datosRecATX (AAx1)	- Arreglo de estructuras con los datos calibrados de
%						antenas.
%	antena				- String con la antena usada. Hasta 15 char.
%	domo				- String con el domo usado. Hasta 4 char.
% 
% DEVOLUCIÓN:
%	datosRecATX			- Estructura con los datos calibrados de la antena	buscada


% Busco la estructura que corresponde al satélite
NATX = length(datosRecATX);

antena_presente = false;

% Recorro todos los datos del ANTEX
for nn = 1:NATX

	flag_antena = strcmp(antena,datosRecATX(nn).Antena);
	flag_domo = strcmp(domo,datosRecATX(nn).Domo);	
	flag_no_domo = strcmp('NONE',datosRecATX(nn).Domo);
	
	if flag_antena
		antena_presente = true;
	end
	
	if flag_antena && flag_no_domo
		indx = nn;
	end
	
	if flag_antena && flag_domo
		
		antexRec = datosRecATX(nn);
		return;
		
	end
	
end

if antena_presente
	
	answer = questdlg('Se han encontrado datos ANTEX de la antena del receptor, pero no del domo utilizado. ¿Desea utilizar datos calibrados de la antena sin domo?', ...
	'Datos ANTEX faltantes','Si','No','Si');

	if strcmp(answer,'Si')
		antexRec = datosRecATX(indx);
	else
		error('Procesamiento interrumpido por faltante de datos ANTEX del receptor');
	end
	
else
	error('Procesamiento interrumpido por faltante de datos ANTEX del receptor');
end
	
end


