# ModulosGNSS

Repositorio de los módulos de procesamiento GNSS en Matlab usados como núcleo de otros programas.


## Instalación

Para poder utilizar las funciones y datos contenidas en estos módulos se debe instalar Matlab en el sistema y agregar la ruta del repositorio.

Para esto, dentro de Matlab entrar a **Set Path**, click en **Add with subfolders** y agregar la dirección donde se haya descargado el repositorio. Al agregar todas las subcarpetas se agregan las correspondientes al control de versiones que no son necesarias, por lo que pueden eliminarse todas las que comienzan con _.git_.


## Descarga automática de datos GNSS

Los módulos permiten automatizar la descarga de datos como archivos de observables, de mensajes de navegación, órbitas y relojes precisos, etc. Para que esta descarga funcione deben cumplirse ciertos pasos adicionales. Estos a su vez dependen de si se está en un sistema Linux o Windows.


### Requisitos adicionales para Windows

La descarga de datos hace uso de funcionalidades propias de Linux, por lo que debe activarse el Subsistema de Linux para Windows. Para esto seguir los siguientes pasos:
* Asegurarse que Windows está actualizado (build 2004 o superior)
* Abrir PowerShell como administrador y ejecutar los siguientes comandos:
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
* Alternativamente (no probado) ir a _Panel de control_ -> _Programas_ -> _Activar o desactivar características de Windows_ y marcar **Subsistema de Linux para Windows** y **Plataforma de máquina virtual**.
* Abrir nuevamente PowerShell y ejecutar el siguiente comando para actualizar al WSL2:
```
wsl --set-default-version 2
```
* Una vez activado el WSL instalar desde la tienda de Microsoft una distribución de Linux, por ejemplo Ubuntu 20.04
* Finalizado esto ya se puede proceder al siguiente punto.

### Creación de cuenta NASA EarthData

Dada la discontinuación del FTP del CDDIS de la NASA, la forma de descargar los datos GNSS es a traves del sistema EarthData. Para usarlo debe crearse una cuenta en 
```
https://urs.earthdata.nasa.gov/
```

El siguiente paso es agregar esas credenciales al sistema. 

* En Linux:
Crear un archivo de nombre _.netrc_ ubicado en _/home_ con el siguiente contenido:
```
machine urs.earthdata.nasa.gov login NombreUsuario password XXXXXX
```
donde NombreUsuario y XXXXXX son el nombre de usuario y contraseña elegidos al crear la cuenta.

* En Windows:
Se debe crear el mismo archivo pero debe ubicarse en el home correspondiente al WSL, el cual no es accesible (fácilmente) desde el Explorador de Windows. Para esto abrir la consola de Ubuntu, ejecutar _nano_, pegar el contenido del archivo, salir y guardar con el nombre _.netrc_

## Versiones

Se recomenienda usar siempre los módulos en sus versiones etiquetadas (ver tags del repositorio). Estas solo se encuentran en los commits de la rama master. Mejoras y adiciones serán incorporadas de la rama devel cuando se consideren versiones estables.

