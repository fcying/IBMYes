#! /bin/bash

cd $(dirname $0)

IBMCLOUD=$(pwd)/Bluemix_CLI/bin/ibmcloud
CF=~/.bluemix/cfcli/cf
#BLUE="\e[00;34m"
#RED="\e[00;31m"
#END="\e[0m"
BLUE=""
RED=""
END="==================================="

if [ ! -f "$IBMCLOUD" ]; then
    echo "${BLUE}download ibm-cloud-cli-release${END}"
    ver=$(curl -s https://github.com/IBM-Cloud/ibm-cloud-cli-release/releases/latest | grep -Po "(\d+\.){2}\d+")
    #ver=1.1.0
    wget -q -Oibm_cli.tgz https://clis.cloud.ibm.com/download/bluemix-cli/$ver/linux64
    if [ $? -eq 0 ]; then
        tar xzf ibm_cli.tgz
    else
        echo "${RED}download new version failed!${END}"
        exit 1
    fi
    rm -fv ibm_cli.tgz
fi

if [ ! -f "./v2ray-cloudfoundry/v2ray/v2ray" ]; then
    echo "${BLUE}download v2ray${END}"
    pushd ./v2ray-cloudfoundry/v2ray
    new_ver=$(curl -s https://github.com/v2fly/v2ray-core/releases/latest | grep -Po "(\d+\.){2}\d+")
    wget -q -Ov2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v${new_ver}/v2ray-linux-64.zip
    if [ $? -eq 0 ]; then
        7z x v2ray.zip v2ray v2ctl
        chmod 700 v2ctl v2ray
    else
        echo "${RED}download new version failed!${END}"
        exit 1
    fi
    rm -fv v2ray.zip
    sed "s/V2_ID/$V2_ID/" config.json -i
    sed "s/V2_PATH/$V2_PATH/" config.json -i
    sed "s/ALTER_ID/$ALTER_ID/" config.json -i
    sed "s/IBM_APP_NAME/$IBM_APP_NAME/" ../manifest.yml -i
    popd
fi

echo "${BLUE}ibmcloud login${END}"
$IBMCLOUD login -r us-south <<EOF
$IBM_ACCOUNT
n
EOF

if [ -n "$RESOURSE_ID" ]; then
    echo "${BLUE}ibmcloud set RESOURSE_ID${END}"
    $IBMCLOUD target -g $RESOURSE_ID
fi

if [ ! -f "$HOME/.bluemix/cfcli/cf" ]; then
    echo "${BLUE}ibmcloud cf install${END}"
    $IBMCLOUD cf install
    $IBMCLOUD target --cf-api 'https://api.us-south.cf.cloud.ibm.com'
fi
$IBMCLOUD target --cf

echo "${BLUE}cf login${END}"
$CF login -a https://api.us-south.cf.cloud.ibm.com <<EOF
$IBM_ACCOUNT
EOF

cd ./v2ray-cloudfoundry
#echo "${BLUE}ibmcloud cf push${END}"
#$IBMCLOUD cf push
echo "${BLUE}cf push${END}"
$CF push
