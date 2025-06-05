#!/bin/bash

NAMESPACE="rtf"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="k8s_diagnostics_${NAMESPACE}_${TIMESTAMP}"
ARCHIVE_NAME="${OUTPUT_DIR}.tar.gz"

mkdir -p "$OUTPUT_DIR"

echo "📂 Output directory: $OUTPUT_DIR"
echo "🔍 Fetching pod list from namespace: $NAMESPACE"

HELM_LOGFILE=helm_install.log
if [[ -r $HELM_LOGFILE ]]; then
  echo copy helm log 
  cp $HELM_LOGFILE $OUTPUT_DIR
fi

if [[ -x ./checkRTF.sh ]]; then
  echo checkRTF.sh
  ./checkRTF.sh > "$OUTPUT_DIR/checkRTF.log" 2>&1
fi

if [[ -x ./rtfctl || $(command -v rtfctl) ]]; then
  echo rtfclt report 
  rtfctl report --overwrite > "$OUTPUT_DIR/rtfclt_report.log" 2>&1
  mv rtf-report.tar.gz $OUTPUT_DIR

  rtfctl test outbound-network --namespace rtf > "$OUTPUT_DIR/rtfclt_ping.log" 2>&1
  rtfctl status --output json --namespace rtf > "$OUTPUT_DIR/rtfclt_status.log" 2>&1
fi

PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
echo "Pods found: " $PODS

for POD in $PODS; do
  echo "🔧 Processing pod: $POD"

  # Logs (all containers)
  echo logs 
  CMD="kubectl logs $POD -n $NAMESPACE --all-containers=true"
  #echo $CMD 
  $CMD > "$OUTPUT_DIR/${POD}.log" 2>&1

  # Describe
  echo decribe 
  kubectl describe pod "$POD" -n "$NAMESPACE" > "$OUTPUT_DIR/${POD}_describe.log" 2>&1
done

# Events
echo events 
kubectl get events -n "$NAMESPACE" --sort-by=.metadata.creationTimestamp > "$OUTPUT_DIR/events.log" 2>&1

echo get pods
kubectl get pods -n "$NAMESPACE" > "$OUTPUT_DIR/get_pods.log" 2>&1

# Create archive
tar -czf "$ARCHIVE_NAME" "$OUTPUT_DIR"

echo "✅ Collection complete."
echo "📦 Archive created: $ARCHIVE_NAME"
