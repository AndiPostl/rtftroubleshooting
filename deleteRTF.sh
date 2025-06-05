# delete RTF cluster 

# helm clean up 
echo helm clean up 
helm repo remove rtf
helm repo list

# list all releases 
helm list
helm uninstall runtime-fabric -n rtf --no-hooks

echo kubectl delete ns rtf
kubectl delete ns rtf

echo kubectl delete priorityclass rtf-components-high-priority
kubectl delete priorityclass rtf-components-high-priority

echo delete crds 
kubectl delete crd httproutetemplates.rtf.mulesoft.com
kubectl delete crd kubernetestemplates.rtf.mulesoft.com
kubectl delete crd persistencegateways.rtf.mulesoft.com

echo kubectl delete  clusterrolebinding rtf-default-binding
kubectl delete  clusterrolebinding rtf-default-binding


echo
echo done 
