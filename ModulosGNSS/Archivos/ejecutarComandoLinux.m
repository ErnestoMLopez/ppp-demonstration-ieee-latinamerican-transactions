function returnValue = ejecutarComandoLinux(comando)
%EJECUTARCOMANDOCONSOLALINUX Ejecuta el comando pasado dependiendo del sistema
% La única función de esta función es agregar el comando wsl para usar
% el subsistema de Linux para Windows en caso de ejecutarse dentro de ese 
% sistema

if ispc
	returnValue = system(['wsl ' comando]);
elseif isunix
	returnValue = system(comando);
end

end

