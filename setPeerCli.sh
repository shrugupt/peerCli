#!/bin/bash
if [ $# -ne 1 ]
then
    echo "Please provide organization name!!!"
else
    orgName=$1
    mkdir -p ./$orgName/msp/{tlscacerts,cacerts,admincerts,keystore,signcerts}
    mkdir -p ./$orgName/tls
    $(cat ./azhlfTool/stores/msp/$orgName.json | jq '.admincerts' | tr -d '"' | base64 -d > ./$orgName/msp/admincerts/cert.pem)
    $(cat ./azhlfTool/stores/msp/$orgName.json | jq '.cacerts' | tr -d '"' | base64 -d > ./$orgName/msp/cacerts/cert.pem)
    $(cat ./azhlfTool/stores/msp/$orgName.json | jq '.tlscacerts' | tr -d '"' | base64 -d > ./$orgName/msp/tlscacerts/ca.crt)
    $(cat ./azhlfTool/stores/wallets/$orgName/admin.$orgName/*-priv > ./$orgName/msp/keystore/key.pem)
    $(cat ./azhlfTool/stores/wallets/$orgName/admin.$orgName/admin.$orgName | jq '.enrollment.identity.certificate' | tr -d '"' | sed 's/\\n/\n/g' > ./$orgName/msp/signcerts/cert.pem)
    $(cat ./azhlfTool/stores/wallets/$orgName/admin.$orgName-tls/*-priv > ./$orgName/tls/key.pem)
    $(cat ./azhlfTool/stores/wallets/$orgName/admin.$orgName-tls/admin.$orgName-tls | jq '.enrollment.identity.certificate' | tr -d '"' | sed 's/\\n/\n/g' > ./$orgName/tls/cert.pem)
    $(cat ./azhlfTool/stores/wallets/$orgName/admin.$orgName-tls/admin.$orgName-tls | jq '.enrollment.identity.certificate' | tr -d '"' | sed 's/\\n/\n/g' > ./$orgName/tls/cert.pem)
    echo "Successfully setup MSP directory"
    export CORE_PEER_LOCALMSPID="$orgName"
    export CORE_PEER_ADDRESS=$(cat ./azhlfTool/stores/connectionprofiles/$orgName.json | jq ".peers[\"peer1.$orgName\"].url" | sed 's/grpcs:\/\///g')
    export CORE_PEER_ID=peercli
    export CORE_PEER_TLS_ENABLED="true"
    export CORE_PEER_TLS_ROOTCERT_FILE=$(pwd)/$orgName/msp/tlscacerts/ca.crt
    export CORE_PEER_TLS_CLIENTAUTHREQUIRED="true"
    export CORE_PEER_TLS_CLIENTCERT_FILE=$(pwd)/$orgName/tls/cert.pem
    export CORE_PEER_TLS_CLIENTKEY_FILE=$(pwd)/$orgName/tls/key.pem
    export CORE_PEER_TLS_CLIENTROOTCAS_FILES=$(pwd)/$orgName/msp/tlscacerts/ca.crt
    export CORE_PEER_MSPCONFIGPATH=$(pwd)/$orgName/msp
    echo "Successfully setup peer CLI environment variables"
fi
