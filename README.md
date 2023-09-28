
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Elasticsearch unassigned shards incident on Kubernetes
---

This incident type refers to a situation where Elasticsearch has unassigned shards. Shards are the basic building blocks of Elasticsearch indexes, and they contain the actual data that is stored in Elasticsearch. When a shard is unassigned, it means that Elasticsearch cannot find a node in the cluster that can hold the shard replicas. This can cause data loss and reduce the performance of the Elasticsearch cluster. Therefore, it is important to address this incident as soon as possible to prevent any potential data loss and maintain the optimal performance of the Elasticsearch cluster.

### Parameters
```shell
export ELASTICSEARCH_NAMESPACE="PLACEHOLDER"

export ELASTICSEARCH_APP="PLACEHOLDER"

export ELASTICSEARCH_SERVICE="PLACEHOLDER"

export ELASTICSEARCH_DEPLOYMENT="PLACEHOLDER"

export ELASTICSEARCH_POD_NAME="PLACEHOLDER"

export NUMBER_OF_REPLICAS="PLACEHOLDER"
```

## Debug

### Check if Elasticsearch pods are running
```shell
kubectl get pods -n ${ELASTICSEARCH_NAMESPACE} -l app=${ELASTICSEARCH_APP}
```

### Check if Elasticsearch service is running
```shell
kubectl get svc -n ${ELASTICSEARCH_NAMESPACE} ${ELASTICSEARCH_SERVICE}
```

### Check if Elasticsearch deployment is running
```shell
kubectl get deployment -n ${ELASTICSEARCH_NAMESPACE} ${ELASTICSEARCH_DEPLOYMENT}
```

### Check if Elasticsearch nodes are healthy
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -XGET 'http://localhost:9200/_cat/nodes?v'
```

### Check if Elasticsearch shards are assigned
```shell
kubectl exec -it ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} curl -XGET 'http://localhost:9200/_cat/shards?v'
```

### Check if Kubernetes nodes have enough resources
```shell
kubectl get nodes --show-labels
```

### Check if there are any pod evictions or disruptions
```shell
kubectl get events -n ${ELASTICSEARCH_NAMESPACE}
```

### Check if there are any Elasticsearch logs related to unassigned shards
```shell
kubectl logs -f ${ELASTICSEARCH_POD_NAME} -n ${ELASTICSEARCH_NAMESPACE} | grep "unassigned"
```

### The Elasticsearch cluster may have insufficient resources such as CPU, memory, or storage space, leading to unassigned shards.
```shell


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


```

## Repair

### Scale the Elasticsearch deployment to add more pods
```shell


#!/bin/bash



# Set the namespace and deployment name

NAMESPACE=${ELACTICSEARCH_NAMESPACE}

DEPLOYMENT_NAME=${ELASTICSEARCH_DEPLOYMENT}



# Set the desired number of replicas

REPLICAS=${NUMBER_OF_REPLICAS}



# Scale the deployment

kubectl scale deployment -n $NAMESPACE $DEPLOYMENT_NAME --replicas=$REPLICAS


```