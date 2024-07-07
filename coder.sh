#!/bin/bash

# Este script genera un archivo de contexto para diferentes tipos de proyectos y envía consultas a ChatGPT
# Colócalo en la carpeta raíz de tu proyecto
# Ejecuta el comando chmod +x coder.sh
# Luego ejecuta ./coder.sh -contexto para generar el archivo de contexto
# O ./coder.sh "tu pregunta" para enviar la pregunta a ChatGPT

# Definir el archivo de log
log_file="coder.log"

# Función para escribir logs
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Función para preguntar al usuario el tipo de proyecto
preguntar_tipo_proyecto() {
  echo "Selecciona el tipo de proyecto:"
  echo "1. React"
  echo "2. Node.js"
  echo "3. Vue.js"
  echo "4. Angular"
  echo "5. Ruby on Rails"
  echo "6. Laravel"
  echo "7. Flask"
  echo "8. Spring Boot"
  echo "9. Express.js"
  echo "10. Flutter"
  read -p "Introduce el número correspondiente: " tipo_proyecto
}

# Función para definir los directorios y archivos a ignorar según el tipo de proyecto
definir_directorios_y_ignorar() {
  case $tipo_proyecto in
    1)
      directorios=("src" "components" "utils" "hooks" "constants")
      ;;
    2)
      directorios=("src" "lib" "controllers" "models" "middlewares" "routes" "utils")
      ;;
    3)
      directorios=("src" "components" "views" "store" "router" "utils")
      ;;
    4)
      directorios=("src" "app" "components" "services" "shared" "utils")
      ;;
    5)
      directorios=("app" "lib" "config" "db" "models" "controllers" "views" "helpers" "assets")
      ;;
    6)
      directorios=("app" "resources" "config" "database" "routes" "public" "storage")
      ;;
    7)
      directorios=("app" "static" "templates" "utils" "migrations" "config")
      ;;
    8)
      directorios=("src" "main" "java" "resources" "config")
      ;;
    9)
      directorios=("src" "lib" "controllers" "models" "middlewares" "routes" "utils")
      ;;
    10)
      directorios=("lib" "assets" "test" "config")
      ;;
    *)
      log "Opción no válida. Saliendo..."
      exit 1
      ;;
  esac

  archivos_ignorar=("*.ico" "*.png" "*.jpg" "*.jpeg" "*.gif" "*.svg" "*.pyc" "*.pyo" "__pycache__" "*.class" "*.jar" "*.woff" "*.woff2" "*.ttf" "*.otf" "*.eot")
}

# Función para verificar si un archivo es de texto
es_archivo_texto() {
  local archivo="$1"
  if file "$archivo" | grep -qE 'text|ASCII|UTF-8'; then
    return 0
  else
    return 1
  fi
}

# Función recursiva para leer archivos y agregar su contenido
leer_archivos() {
  local dir_actual="$1"

  for entrada in "$dir_actual"/*; do
    if [ -d "$entrada" ]; then
      leer_archivos "$entrada"
    elif [ -f "$entrada" ]; then
      for patron_ignorar in "${archivos_ignorar[@]}"; do
        if [[ "$entrada" == $patron_ignorar ]]; then
          continue 2
        fi
      done

      if es_archivo_texto "$entrada"; then
        ruta_relativa=${entrada#"$directorio_proyecto/"}
        echo "// Archivo: $ruta_relativa" >> "$archivo_salida"
        cat "$entrada" >> "$archivo_salida"
        echo "" >> "$archivo_salida"
      fi
    fi
  done
}

# Función para generar el archivo de contexto
generar_contexto() {
  log "Generando archivo de contexto..."
  
  # Preguntar al usuario el tipo de proyecto
  preguntar_tipo_proyecto

  # Definir los directorios y archivos a ignorar según el tipo de proyecto
  definir_directorios_y_ignorar

  # Establecer el directorio del proyecto como el directorio actual
  directorio_proyecto=$(pwd)

  # Establecer el nombre del archivo de salida en el directorio actual
  archivo_salida="${directorio_proyecto}/contexto_codigo.txt"

  # Si el archivo de salida existe, eliminarlo
  [ -f "$archivo_salida" ] && rm "$archivo_salida"

  # Llamar a la función recursiva para cada directorio especificado en el directorio del proyecto
  for dir in "${directorios[@]}"; do
    [ -d "${directorio_proyecto}/${dir}" ] && leer_archivos "${directorio_proyecto}/${dir}"
  done

  log "Archivo de contexto generado en $archivo_salida"
}

# Función para enviar la consulta a ChatGPT
consultar_chatgpt() {
  local pregunta="$1"
  local api_key="OPEN-AI-API-TOKEN"  # Reemplaza esto con tu clave API de OpenAI
  local contexto

  if [ -f "contexto_codigo.txt" ]; then
    contexto=$(<contexto_codigo.txt)
  else
    log "El archivo contexto_codigo.txt no existe. Ejecuta ./coder.sh -contexto primero."
    exit 1
  fi

  local prompt="$contexto

Pregunta: $pregunta"

  log "Enviando consulta a ChatGPT..."
  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" https://api.openai.com/v1/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $api_key" \
    -d '{
      "model": "text-davinci-003",
      "prompt": "'"${prompt//\"/\\\"}"'",
      "max_tokens": 1000,
      "temperature": 0.5
    }')

  http_status=$(echo "$response" | sed -n 's/.*HTTP_STATUS://p')
  body=$(echo "$response" | sed -e 's/HTTP_STATUS:.*//g')

  if [ "$http_status" -eq 200 ]; then
    log "Respuesta recibida de ChatGPT"
    echo "$body" | jq -r '.choices[0].text'
  else
    log "Error al recibir respuesta de ChatGPT. Código de estado HTTP: $http_status"
    echo "Error: $(echo "$body" | jq -r '.error.message')"
  fi
}

# Verificar argumentos y ejecutar la lógica correspondiente
if [ "$1" == "-contexto" ]; then
  generar_contexto
elif [ -n "$1" ]; then
  consultar_chatgpt "$*"
else
  echo "Uso: ./coder.sh -contexto | \"tu pregunta\""
fi