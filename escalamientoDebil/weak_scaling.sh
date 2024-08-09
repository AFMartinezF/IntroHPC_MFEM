#!/bin/bash
#El comando !/bin/bash indica que el script se ejecutará en bash
#Esto es esencial para scripts que utilizan características
#específicas de Bash que no están disponibles en otros shells
#como sh (Shell estándar de UNIX).

# Limpiar archivos de salida al comienzo
> metrics.txt

TARGET=ex1p_v3
MAX_THREADS=16
THREADS=$(seq 1 $MAX_THREADS)
REPS=$(seq 1 10)
ORDER=3


# Loop para ejecutar comandos
for thread in $THREADS; do
    echo -e "Ejecucion para el thread: $thread\n"
    for Nreps in $REPS; do
        echo -e "Repeticion: $Nreps\n"
        /usr/bin/time -f "%S" mpirun -np $thread ./${TARGET} -o $ORDER  1>> /dev/null 2>>time$thread.txt
    done
    # Calcular el promedio
    average=$(awk '{ sum += $1 } END { if (NR > 0) print sum / NR }' time$thread.txt)

    # Calcular la desviación estándar
    stdev=$(awk -v avg="$average" '{ sumsq += ($1 - avg)^2 } END { if (NR > 1) print sqrt(sumsq / (NR - 1)) }' time$thread.txt)

    # Guardar el promedio y la desviación estándar en time.txt
    echo "$thread $average $stdev" >> time.txt
done

T1=$(awk 'NR==1 {print $2}' time.txt)

awk '{print $1, '$T1'/$2, '$T1'/$2/$1}' time.txt > metrics.txt

python plot.py

for ((i=1; i<=$MAX_THREADS; i++)); do
    rm time${i}.txt
done

rm mesh* sol*
