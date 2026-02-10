#!/bin/bash

ESHOST="http://localhost:9200"


function es_indices() {
  curl -X GET "${ESHOST}/_cat/indices?v"
}

indexList=$(es_indices 2> /dev/null | awk '{ print $3 }' | grep -v "^index$")


for name in $indexList; do
    echo curl -iv -X DELETE "${ESHOST}/$name"
    curl -iv -X DELETE "${ESHOST}/$name"
done
