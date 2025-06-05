###########################
# Install RTF 2025
###########################


#if [[ -z "${RTF_ACTIVATION_DATA}" ]]; then
#  echo "❌ ERROR: RTF_ACTIVATION_DATA environment variable is not set."
#  echo
#  echo "export RTF_ACTIVATION_DATA=abec from Anypoint Runtime Manager > Runtime Fabric" 
#  exit 1
#fi

read -rp "🔐 Enter RTF Activation Data: " RTF_ACTIVATION_DATA
export RTF_ACTIVATION_DATA

echo "✅ RTF_ACTIVATION_DATA is set. $RTF_ACTIVATION_DATA"


###########################
#Start Config
RTF_NAMESPACE=rtf
DOCKER_USERNAME=r7zHc1fe2a/eu-central-1/edef00ff7a3845a2af97dc601f8f38ff
DOCKER_PW=EcFcDA9057B84E9fA5F83Fe9b15acB1b


if [[ "$DOCKER_USERNAME" == *"eu-central-1"* ]]; then
  DOCKER_REGISTRY="rtf-runtime-registry.kprod-eu.msap.io"
else
  DOCKER_REGISTRY="rtf-runtime-registry.kprod.msap.io"
fi

echo "DOCKER_REGISTRY is set to: $DOCKER_REGISTRY"
#End Config
###########################


#VALUES_YAML=/Users/apostl/openshift/helm_rtf_values.yaml.template
VALUES_YAML=helm_rtf_values.yaml.template

if [ ! -r "$VALUES_YAML" ]; then
    echo "Error: '$VALUES_YAML' is not readable or does not exist"
    exit 1
fi


###################################
# Step 1: kubectl create ns 
###################################
echo
echo "Step 1: kubectl create ns $RTF_NAMESPACE" 
kubectl create ns $RTF_NAMESPACE

ERR=$?
if [ $ERR -ne 0 ]; then
    echo
    echo "Command failed with exit code $ERR"
else
    echo "Command executed successfully"
fi


#################################################################
# Step 2: kubectl create secret docker-registry rtf-pull-secret 
#################################################################
echo
echo "Step 2: kubectl create secret docker-registry rtf-pull-secret --namespace $RTF_NAMESPACE" 
kubectl create secret docker-registry rtf-pull-secret --namespace $RTF_NAMESPACE \
--docker-server=$DOCKER_REGISTRY \
--docker-username=$DOCKER_USERNAME \
--docker-password=$DOCKER_PW

ERR=$?
if [ $ERR -ne 0 ]; then
    echo
    echo "Command failed with exit code $ERR"
else
    echo "Command executed successfully"
fi


#################################################################
# Step 3: helm repo add rtf
#################################################################
echo
echo "Step 3: helm repo add rtf" 
helm repo add rtf https://${DOCKER_REGISTRY}/charts \
--username $DOCKER_USERNAME \
--password $DOCKER_PW

ERR=$?
if [ $ERR -ne 0 ]; then
    echo
    echo "Command failed with exit code $ERR"
    exit 1
else
    echo "Command executed successfully"
fi


#################################################################
# Step 4: helm upgrade --install
#################################################################
echo 
echo "Step 4: helm upgrade --install" 
sed -e "s/ACTIVATION_DATA_PLACEHOLDER/$RTF_ACTIVATION_DATA/" -e "s/RTF_REGISTRY_PLACEHOLDER/$DOCKER_REGISTRY/" "$VALUES_YAML" > helm_rtf_values.yaml

HELM_LOGFILE=helm_install.log
if [ -r "$HELM_LOGFILE" ]; then
    rm $HELM_LOGFILE
fi 

helm upgrade --install runtime-fabric rtf/rtf-agent -f helm_rtf_values.yaml --version 2.10.17 -n $RTF_NAMESPACE --debug &> $HELM_LOGFILE

ERR=$?
if [ $ERR -ne 0 ]; then
    echo
    echo "Command failed with exit code $ERR"
else
    echo "Command executed successfully"
fi

echo "Logs in $HELM_LOGFILE" 
echo "Done :)" 
