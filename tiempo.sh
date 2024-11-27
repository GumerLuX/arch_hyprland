#!/bin/bash

# Registrar el tiempo de inicio
start_time=$(date +%s)

# ----- INICIO DE TU LÓGICA -----
echo "Comenzando tareas..."



echo "Finalizando tareas..."
# ----- FIN DE TU LÓGICA -----

# Registrar el tiempo de finalización
end_time=$(date +%s)

# Calcular el tiempo de ejecución
execution_time=$((end_time - start_time))

# Convertir a un formato legible
hours=$((execution_time / 3600))
minutes=$(((execution_time % 3600) / 60))
seconds=$((execution_time % 60))

# Mostrar el tiempo total de ejecución
echo "Tiempo de ejecución: ${hours}h ${minutes}m ${seconds}s"
