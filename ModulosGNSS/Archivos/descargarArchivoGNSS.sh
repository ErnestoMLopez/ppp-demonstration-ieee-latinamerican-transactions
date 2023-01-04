#!/bin/bash

# Modo de uso:  ./descargarArchivoGNSS ../save/dir https://direccion.com nombrearchivo.txt

SAVEDIR=$1
FILEDIR=$2
FILENAME=$3

# Si estoy en Windows convierto la dirección de guardado al formato WSL (/mnt/d/...)
if grep -q microsoft /proc/version; then
  echo "Ubuntu on Windows WSL"
  FINALSAVEDIR=$(wslpath "${SAVEDIR}")
else
  echo "Native Linux"
  FINALSAVEDIR=${SAVEDIR}
fi

# Creo la carpeta donde voy a guardar los archivos ya convertidos
mkdir -p "${FINALSAVEDIR}"

# Intento descargar el archivo
wget --no-hsts --auth-no-challenge -q -nc -P "${FINALSAVEDIR}" "${FILEDIR}${FILENAME}"

if [ $? -eq 8 ]; then
	echo "No se pudo encontrar el archivo: ${FILEDIR}${FILENAME}"

	nom="${FILENAME%.*}"
	ext="${FILENAME##*.}"
	if [ "$ext" = "Z" ]; then
    	newext="gz"
	elif [ "$ext" = "gz" ]; then
    	newext="Z"
	fi

	FILENAME="${nom}.${newext}"
	
	echo "Intentando descargar el archivo: ${FILEDIR}${FILENAME}"

	wget --no-hsts --auth-no-challenge -q -nc -P "${FINALSAVEDIR}" "${FILEDIR}${FILENAME}"

	if [ $? -eq 8 ]; then
		retval=8
    	return "$retval"
    else
    	uncompress -f "${FINALSAVEDIR}${FILENAME}"
    fi
else
	# Descomprimo el archivo descargado
	uncompress -f "${FINALSAVEDIR}${FILENAME}"
fi





