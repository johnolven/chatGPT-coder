
# Generador de Contexto y Consultas a ChatGPT

Este script permite generar un archivo de contexto para diferentes tipos de proyectos y enviar consultas a ChatGPT. Coloca el script en la carpeta raíz de tu proyecto.

## Instalación

1. Clona este repositorio o descarga el archivo `coder.sh`.
2. Coloca `coder.sh` en la carpeta raíz de tu proyecto.
3. Da permisos de ejecución al script:

   ```bash
   chmod +x coder.sh
   ```

## Uso

### Generar Archivo de Contexto

Para generar un archivo de contexto, ejecuta:

```bash
./coder.sh -contexto
```

### Consultar a ChatGPT

Para enviar una consulta a ChatGPT, ejecuta:

```bash
./coder.sh "tu pregunta"
```

## Alias para Ejecutar el Script

Para facilitar la ejecución del script, puedes crear un alias en tu archivo de configuración de shell (`~/.bashrc`, `~/.zshrc`, etc.). Añade la siguiente línea:

```bash
alias coder='~/ruta/al/directorio/coder.sh'
```

Reemplaza `~/ruta/al/directorio/coder.sh` con la ruta real al script en tu sistema. Luego, recarga tu archivo de configuración de shell:

```bash
source ~/.bashrc  # o source ~/.zshrc
```

Ahora puedes ejecutar el script usando el alias:

```bash
coder -contexto
coder "tu pregunta"
```

## Registro de Logs

El script genera un archivo de log llamado `coder.log` en el directorio donde se ejecuta. Este archivo registra las operaciones realizadas por el script.

## Configuración de API Key

Para enviar consultas a ChatGPT, necesitas una API key de OpenAI. Reemplaza el valor `OPEN-AI-API-TOKEN` en el script con tu clave API.

```bash
local api_key="OPEN-AI-API-TOKEN"
```
