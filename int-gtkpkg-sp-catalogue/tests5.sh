#!/bin/bash
printf "\n\n======== GET Package UUID from Gatekeeper  ========\n\n\n"
resp=$(curl -qSfsw '\n%{http_code}' -H "Content-Type: application/json" -X GET http://sp.int3.sonata-nfv.eu:32001/packages) 2>/dev/null
echo $resp

package=$(echo "$resp" | head -n-1)
uuid=$(echo $package  |  python -mjson.tool | grep "uuid" | awk -F'[=:]' '{print $2}' | sed 's/\"//g' | tr -d ',')
echo "UUID: $uuid"

printf "\n\n======== GET SON Package from Gatekeeper ========\n\n\n"
resp=$(curl -qSfsw '\n%{http_code}' -X GET http://sp.int3.sonata-nfv.eu:32001/packages/${uuid}) 2>/dev/null
echo $resp

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 200 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

