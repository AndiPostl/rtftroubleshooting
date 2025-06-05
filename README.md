# RTF troubleshooting


Helm and kubectl need to be installed and configured.

Install rtfclt (only intel/AMD NOT ARM architecture)
https://docs.mulesoft.com/runtime-fabric/latest/install-rtfctl

For Linux 
```
curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/rtfctl/latest -o rtfctl
```
```
unzip rtftroubleshooting.zip 
```
```
cd rtftroubleshooting
```
```
chmod +x *.sh 
```

# Prepare 

Download this repo
```
curl -L -o rtftroubleshooting.zip https://github.com/AndiPostl/rtftroubleshooting/archive/refs/heads/main.zip
```



# Delete RTF
```
./deleteRTF.sh
```

# Install RTF
```
./installRTF.sh
```

# Check installation
```
kubectl get pods -n rtf
```
```
./checkRTF.sh
```

# Collect kubernetes diagnostic data and store it in tgz 
```
./collect-rtf-diagnostics.sh
```

# OKE CRIO images 

Check OKE image cache
```
./list-crio-images.sh
```

Clean OKE image cache for MuleSoft 
```
./cleanup-mulesoft-images.sh
```

# Python connectivity test
```
kubectl apply -f connectiontest-deployment.yaml -n rtf
```
```
kubectl get pods -n rtf
```
```
kubectl logs -f -n rtf connection-test-xxxxx
```
