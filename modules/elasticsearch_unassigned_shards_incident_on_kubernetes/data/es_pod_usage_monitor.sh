

#!/bin/bash



# Set the Elasticsearch namespace and pod name

NAMESPACE="${ELASTICSEARCH_NAMESPACE}"

POD_NAME="${ELASTICSEARCH_POD_NAME}"



# Check the CPU usage of the Elasticsearch pod

CPU_USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "ps -p 1 -o %cpu | tail -1")

if (( $(echo "$CPU_USAGE > 80.0" | bc -l) )); then

  echo "WARNING: CPU usage of Elasticsearch pod is high: $CPU_USAGE%"

fi



# Check the memory usage of the Elasticsearch pod

MEMORY_USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "free -m | awk 'NR==2{printf \"%s/%sMB (%.2f%%)\", $3,$2,$3*100/$2 }'")

if (( $(echo "$MEMORY_USAGE" | awk -F'[(%)]' '{print $2}' | awk '{print int($1)}') > 80 )); then

  echo "WARNING: Memory usage of Elasticsearch pod is high: $MEMORY_USAGE"

fi



# Check the storage space usage of the Elasticsearch pod

STORAGE_USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -- sh -c "df -h /usr/share/elasticsearch/data | awk '{print $5}' | tail -1 | sed 's/%//g'")

if (( $STORAGE_USAGE > 80 )); then

  echo "WARNING: Storage space usage of Elasticsearch pod is high: $STORAGE_USAGE%"

fi