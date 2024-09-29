#!/bin/bash

# WARNING NO EJECUTAR - ESTO ES PELIGROSO
# WARNING Estoy preparando este script para añadir con ficheros que seran los que borra
# WARNING Ahora estan puesto aqui dentro y podrian eliminar cosas que necesitas
# WARNING Lo separare enb ficheros configurables, esto es para pruebas

# Directorio donde están los proyectos
# nombre.dominio/webdocs/http

################################################################################
# Script para limpiar directorios de proyectos eliminando subdirectorios vacíos,
# subdirectorios específicos incluso si no están vacíos, y archivos mayores de 
# 100MB con opción de confirmación para su eliminación.
#
# - Elimina subdirectorios vacíos de una lista predefinida.
# - Elimina subdirectorios especificados incluso si contienen archivos.
# - Encuentra y muestra archivos grandes (>100MB) permitiendo al usuario elegir 
#   si desea eliminarlos.
# - Comprime dentro de cada carpeta webdocs y elimina webdocs
#
# Uso: ./nombre_script.sh
#
# Requiere permisos adecuados para modificar archivos y directorios.
################################################################################


DIRECTORIO_BASE="./"

# Subdirectorios a eliminar si si
SUBDIRECTORIOS_A_ELIMINAR=("temp" "other" "https" "../ssl" ".gnupg" ".lhistory")

# Subdirectorios a eliminar solo si estan vacios
SUBDIRECTORIOS_VACIOS=("https" "includes" "cgi-bin")



# Función para eliminar subdirectorios vacíos
eliminar_subdirectorios_vacios() {
  local directorio=$1
  for subdir in "${SUBDIRECTORIOS_VACIOS[@]}"; do
    # Ruta completa del subdirectorio
    subdir_completo="$directorio/webdocs/$subdir"
    # Verificar si el subdirectorio existe y está vacío
    if [[ -d "$subdir_completo" && -z "$(ls -A "$subdir_completo")" ]]; then
      rmdir -v "$subdir_completo"
    fi
  done
}

# Función para eliminar subdirectorios, aunque no estén vacíos
eliminar_subdirectorios() {
  local directorio=$1
  for subdir in "${SUBDIRECTORIOS_A_ELIMINAR[@]}"; do
    # Ruta completa del subdirectorio
    subdir_completo="$directorio/webdocs/$subdir"
    # Verificar si el subdirector existe
    if [[ -d "$subdir_completo" ]]; then
      rm -rf "$subdir_completo"
      echo "Directorio eliminado: $subdir_completo"
    fi
  done
}


echo "Se han eliminado: "

# Recorre todos los directorios en el directorio base
for proyecto in "$DIRECTORIO_BASE"/*/; do
  eliminar_subdirectorios_vacios "$proyecto"
  eliminar_subdirectorios "$proyecto"
done

echo "Eliminando ficheros de mas de 100MB: "

# Buscar archivos mayores de 100MB y mostrar su tamaño
find "$DIRECTORIO_BASE" -type f -size +100M | while read -r file; do
    # Mostrar el tamaño del archivo
    echo "El archivo '$file' ocupa $(du -h "$file" | cut -f1)"
    
    # Preguntar al usuario si desea borrar el archivo
    read -p "¿Deseas borrar este archivo? (y/n): " response </dev/tty
    
    # Validar la respuesta del usuario
    if [ "$response" = "y" ]; then
        rm "$file"  # Borrar el archivo si el usuario responde "y"
        echo "Archivo '$file' borrado."
    else
        echo "Archivo '$file' no borrado."
    fi
done

echo "Listando directorios hasta 3 niveles: "

find "$DIRECTORIO_BASE" -maxdepth 3 -type d 

echo "Mostrando espacio ocupado: "

du -c -s -h "$DIRECTORIO_BASE"*



echo "Comprimir: "

# Función para comprimir directorio en tar.gz
comprimir_directorio() {
    local directorio=$1
    local fecha=$(date +"%Y%m%d")  # Fecha actual en formato YYYYMMDD
    local archivo_salida="${directorio}_$fecha.tar.gz"
    
    # Comprobar si el directorio existe
    if [ -d "$directorio" ]; then
        # Crear archivo tar.gz del directorio
        tar -czvf "$archivo_salida" -C "$(dirname "$directorio")" "$(basename "$directorio")"
        md5sum $archivo_salida > $archivo_salida.md5
        echo "Directorio '$directorio' comprimido como '$archivo_salida'"
    else
        echo "Error: el directorio '$directorio' no existe o no es válido."
    fi
}

# Función para recorrer directorios hasta 2 niveles de profundidad
recorrer_directorios() {
    local nivel_actual=$1
    local max_nivel=2
    local directorio_base=$2
    
    # Salir si el nivel actual supera el máximo nivel
    if [ "$nivel_actual" -gt "$max_nivel" ]; then
        return
    fi
    
    # Recorrer cada carpeta hasta el máximo nivel
    find "$directorio_base" -mindepth "$nivel_actual" -maxdepth "$nivel_actual" -type d | while read -r carpeta; do
        # Mostrar carpeta actual
        echo "Carpeta encontrada: $carpeta"
        du -c -s -h $carpeta |grep -v total
        # Preguntar al usuario si desea comprimir esta carpeta
        read -p "¿Deseas comprimir esta carpeta? (y/n): " respuesta </dev/tty
        
        if [ "$respuesta" = "y" ]; then
            # Comprimir el directorio
            comprimir_directorio "$carpeta"
        fi
    done
}

# Iniciar recorrido desde el directorio base
recorrer_directorios 1 "./"















