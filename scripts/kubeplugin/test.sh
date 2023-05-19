#!/bin/bash

# Define command-line arguments
NAMESPACE=$1

# Retrieve pod information with CPU, memory, and name
kubectl get pods -n "$NAMESPACE" --template='{{range .items}}{{.metadata.name}},{{if .spec.containers}}{{index .spec.containers 0 "resources" "requests" "cpu"}},{{index .spec.containers 0 "resources" "requests" "memory"}}{{else}}N/A,N/A{{end}}{{"\n"}}{{end}}'
