#!/bin/bash

set -e

NAMESPACE="kube-system"
DAEMONSET_NAME="crio-image-lister"
LABEL_SELECTOR="app=${DAEMONSET_NAME}"

echo "📦 Deploying DaemonSet: $DAEMONSET_NAME"

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ${DAEMONSET_NAME}
  namespace: ${NAMESPACE}
spec:
  selector:
    matchLabels:
      app: ${DAEMONSET_NAME}
  template:
    metadata:
      labels:
        app: ${DAEMONSET_NAME}
    spec:
      hostPID: true
      hostNetwork: true
      restartPolicy: Always
      containers:
      - name: lister
        image: alpine:3.18
        securityContext:
          privileged: true
        command:
          - /bin/sh
          - -c
          - |
            echo "Installing crictl..."
            wget -qO- https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.31.0/crictl-v1.31.0-linux-amd64.tar.gz | tar -xz -C /usr/local/bin
            echo "runtime-endpoint: unix:///var/run/crio/crio.sock" > /etc/crictl.yaml
            echo "Listing cached CRI-O images on this node:"
            crictl images
            echo "Sleeping to keep pod alive for inspection..."
            sleep 3600
        volumeMounts:
        - name: var-run
          mountPath: /var/run
        - name: etc-crio
          mountPath: /etc/crio
      volumes:
      - name: var-run
        hostPath:
          path: /var/run
      - name: etc-crio
        hostPath:
          path: /etc/crio
EOF

echo "⏳ Waiting for DaemonSet pods to be ready..."
kubectl wait --for=condition=Ready pod -l app=$DAEMONSET_NAME -n $NAMESPACE --timeout=60s || echo "Warning: Some pods may not be ready."

echo ""
echo "📄 Fetching logs from DaemonSet pods:"
for pod in $(kubectl get pods -n $NAMESPACE -l app=$DAEMONSET_NAME -o name); do
  echo "----- Logs from $pod -----"
  kubectl logs -n $NAMESPACE "$pod"
  echo ""
done

read -p "🧹 Do you want to delete the DaemonSet now? (y/N): " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "🗑️ Deleting DaemonSet..."
  kubectl delete daemonset $DAEMONSET_NAME -n $NAMESPACE
else
  echo "🛑 DaemonSet retained. Clean it up manually later if needed."
fi
