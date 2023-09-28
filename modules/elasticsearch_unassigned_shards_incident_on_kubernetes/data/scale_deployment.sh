

#!/bin/bash



# Set the namespace and deployment name

NAMESPACE=${ELACTICSEARCH_NAMESPACE}

DEPLOYMENT_NAME=${ELASTICSEARCH_DEPLOYMENT}



# Set the desired number of replicas

REPLICAS=${NUMBER_OF_REPLICAS}



# Scale the deployment

kubectl scale deployment -n $NAMESPACE $DEPLOYMENT_NAME --replicas=$REPLICAS