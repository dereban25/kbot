Run script with Memory CPU and Name in kubernetes 
#!/bin/bash

# Define command-line arguments
NAMESPACE=$2
RESOURCE_TYPE=$1

# Retrieve resource usage statistics from Kubernetes
kubectl top $RESOURCE_TYPE -n $NAMESPACE | tail -n +2 | while read -r line
do
  # Extract CPU and memory usage from the output
  NAME=$(echo "$line" | awk '{print $1}')
  CPU=$(echo "$line" | awk '{print $2}')
  MEMORY=$(echo "$line" | awk '{print $3}')

  # Output the statistics to the console
  echo "Resource: $RESOURCE_TYPE, Namespace: $NAMESPACE, Name: $NAME, CPU: $CPU, Memory: $MEMORY"
done