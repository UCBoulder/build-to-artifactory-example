#!/bin/bash

printf "$(basename $0): Checking that container started with healthy status...\n"

for (( i = 31; i > 0 ; i-- )) do
  health=$(docker ps -a | grep healthy)
    if [[ $health =~ healthy ]]; then
    printf "$(basename $0): Container is healthy.\n"
    exit 0 
  fi
  sleep 10
  printf "$(basename $0): Container not yet healthy... $i attempts remaining.\n"
done

>&2 printf "$(basename $0): Failed, container did not become healthy in time.\n"

exit 1
