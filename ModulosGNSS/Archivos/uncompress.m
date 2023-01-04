function [ z ] = uncompress( filename )
%UNCOMPRESS Summary of this function goes here
%   Detailed explanation goes here
filedir = strsplit(filename, '/');
file = filedir{length(filedir)};
filedir = strjoin(filedir(1:length(filedir)-1),'\');

% Chequeo el SO y seteo el comando a utilizar..
if ispc
    % Caso WINDOWS:
    % Por como funciona 7-Zip, tengo que cambiar de directorio.
    prevdir = cd (filedir);
    
    % Verifico la ruta al 7-Zip.
    if ~isempty(dir('C:\Program Files\7-Zip\7z.exe '))
        % Si la ruta es valida, armo el comando.
        unpackerRoute = '"C:\Program Files\7-Zip\7z.exe"';
        command = [unpackerRoute, ' x -bso0 -y ', file];
    
    elseif ~isempty(dir('C:\Program Files (x86)\7-Zip\7z.exe '))
        % Caso 7-Zip (32bit) - Si la ruta es valida, armo el comando.
        unpackerRoute = '"C:\Program Files (x86)\7-Zip\7z.exe"';
        command = [unpackerRoute, ' x -bso0 -y ', file];
    
        % -----------------------------------------------------------------
        % Se pueden seguir agregando casos de desempaquetadores en caso de
        % requerirlo, o tratar de pasar una ruta propia, pero involucra un
        % know-how mas molesto que pedir que instalen el 7-zip.
        % -----------------------------------------------------------------
    else
        % Si no se encuentra instalado 7-Zip.
        fprintf('No se encuentra un desempaquetador.');
    end
    
elseif isunix
    % Caso UNIX:
    % Mira que facil.
    unpackerRoute = 'uncompress ';
    command = [unpackerRoute, ' -f ', filename];
    
else
    % Caso contrario.
    fprintf('Uncompress no implementado para este OS.');
    z = -1;
    return;  
end

% Ejecuto el comando.
system(command);

% Si estoy en Windows, elimino el archivo y vuelvo al directorio anterior.
if ispc
    delete(file);
    cd(prevdir);
end

% Retorno 0.
z = 0;

end