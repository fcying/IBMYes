#! /bin/bash

cd $(dirname $0)

IBMCLOUD=$(pwd)/Bluemix_CLI/bin/ibmcloud

if [ ! -f "$IBMCLOUD" ]; then
    ver=$(curl -s https://github.com/IBM-Cloud/ibm-cloud-cli-release/releases/latest | grep -Po "(\d+\.){2}\d+")
    wget -q -Oibm_cli.tgz https://clis.cloud.ibm.com/download/bluemix-cli/$ver/linux64
    if [ $? -eq 0 ]; then
        tar xzf ibm_cli.tgz
    else
        echo "download new version failed!"
        exit 1
    fi
    rm -fv ibm_cli.tgz
fi

if [ ! -f "./v2ray-cloudfoundry/v2ray/v2ray" ]; then
    pushd ./v2ray-cloudfoundry/v2ray
    new_ver=$(curl -s https://github.com/v2fly/v2ray-core/releases/latest | grep -Po "(\d+\.){2}\d+")
    wget -q -Ov2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v${new_ver}/v2ray-linux-64.zip
    if [ $? -eq 0 ]; then
        7z x v2ray.zip v2ray v2ctl
        chmod 700 v2ctl v2ray
    else
        echo "download new version failed!"
        exit 1
    fi
    rm -fv v2ray.zip
    sed "s/V2_ID/$V2_ID/" config.json -i
    sed "s/V2_PATH/$V2_PATH/" config.json -i
    sed "s/ALTER_ID/$ALTER_ID/" config.json -i
    sed "s/IBM_APP_NAME/$IBM_APP_NAME/" ../manifest.yml -i
    popd
fi

$IBMCLOUD login -r us-south <<EOF
$IBM_ACCOUNT
n
EOF

if [ ! -f "$HOME/.bluemix/cfcli/cf" ]; then
    $IBMCLOUD cf install
    $IBMCLOUD target --cf-api 'https://api.us-south.cf.cloud.ibm.com'
fi

cd ./v2ray-cloudfoundry
if [ -n "$RESOURSE_ID" ]; then
    $IBMCLOUD target -g $RESOURSE_ID
fi
$IBMCLOUD target --cf

$IBMCLOUD cf push
