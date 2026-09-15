#!/bin/bash

limit=$((48 * 3600))  # 48 horas en segundos
now=$(date +%s)

for img in $(docker images -q); do
    created=$(docker inspect --format='{{.Created}}' $img | xargs date +%s -d)
    age=$((now - created))

    if [ $age -gt $limit ]; then
        echo "Eliminando imagen $img (edad: $age segundos)"
        docker rmi $img
    fi
done

