#!/bin/bash

NAMESPACE="rtf"
echo "Checking Kubernetes resources in namespace: $NAMESPACE"
echo "---------------------------------------------"

# CRDs GLOBAL
echo "🔍 GLOBAL Checking CustomResourceDefinitions:"
kubectl get crd | grep -E 'httproutetemplates|kubernetestemplates|persistencegateways'

# ClusterRoles GLOBAL
echo -e "\n🔍 GLOBAL Checking ClusterRoles:"
kubectl get clusterrole | grep -E 'am-log-forwarder-default|rtf:agent-default|rtf:agent:common-default|rtf:mule-clusterip-service-default|rtf:persistence-gateway-clro-read-only-default'

# ClusterRoleBindings GLOBAL
echo -e "\n🔍 GLOBAL Checking ClusterRoleBindings:"
kubectl get clusterrolebinding | grep -E 'am-log-forwarder-default|restricted-psp-user|rtf-default-binding-default|rtf:agent-default|rtf:mule-clusterip-service-default|rtf:persistence-gateway-clro-read-only-default|rtf:persistence-gateway-crb-read-only-default'

# ConfigMaps
echo -e "\n🔍 Checking ConfigMaps:"
kubectl get configmap -n $NAMESPACE 

# Deployments
echo -e "\n🔍 Checking Deployments:"
kubectl get deployments -n $NAMESPACE 

# Jobs
echo -e "\n🔍 Checking Jobs:"
kubectl get jobs -n $NAMESPACE 

# PriorityClass GLOBAL
echo -e "\n🔍 GLOBAL Checking PriorityClass:"
kubectl get priorityclass | grep rtf-components-high-priority

# Services
echo -e "\n🔍 Checking Services:"
kubectl get svc -n $NAMESPACE 

# ServiceAccounts
echo -e "\n🔍 Checking ServiceAccounts:"
kubectl get serviceaccount -n $NAMESPACE 

# Secrets
echo -e "\n🔍 Checking Secrets:"
kubectl get secret -n $NAMESPACE 

echo -e "\n✅ Check complete."
