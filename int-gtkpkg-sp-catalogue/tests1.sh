#!/bin/bash
printf "\n\n======== POST Package to Gatekeeper ========\n\n\n"
### Login phase
echo "Authenticating to the Service Platform..."

resp=$(curl -qSfsw '\n%{http_code}' -d '{"username":"jenkins","password":"1234"}' \
http://sp.int3.sonata-nfv.eu:32001/api/v2/sessions)
echo $resp

token=$(echo $resp | awk '{json=$1 FS $2 FS $3; print json}' | python -mjson.tool | grep "access_token" | awk -F ':[ \t]*' '{print $2}' | sed 's/,//g' | sed 's/"//g')
echo "TOKEN="$token

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 200 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

sleep 1

# Test phase
#resp=$(curl -qSfsw '\n%{http_code}' -F "package=@resources/sonata-demo.son" -H "Authorization: Bearer $token" \
# -X POST http://sp.int3.sonata-nfv.eu:32001/api/v2/packages)
resp=$(curl -qSfsw '\n%{http_code}' -F "package=@int-gtkpkg-sp-catalogue/resources/sonata-demo.son" -H "Authorization: Bearer $token" \
-X POST http://sp.int3.sonata-nfv.eu:32001/api/v2/packages)
echo $resp

package=$(echo $resp | grep "uuid")

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 201 ]] && [[ $code != 409 ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

sleep 1

### Logout phase
echo "Log-out of the Service Platform..."
resp=$(curl -qSfsw '\n%{http_code}' -H "Authorization: Bearer $token" \
-X DELETE http://sp.int3.sonata-nfv.eu:32001/api/v2/sessions) 2>/dev/null
echo $resp

code=$(echo "$resp" | tail -n1)
echo "Code: $code"

if [[ $code != 20* ]] ;
  then
    echo "Error: Response error $code"
    exit -1
fi

sleep 1


