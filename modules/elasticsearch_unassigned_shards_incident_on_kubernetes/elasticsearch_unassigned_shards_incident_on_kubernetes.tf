resource "shoreline_notebook" "elasticsearch_unassigned_shards_incident_on_kubernetes" {
  name       = "elasticsearch_unassigned_shards_incident_on_kubernetes"
  data       = file("${path.module}/data/elasticsearch_unassigned_shards_incident_on_kubernetes.json")
  depends_on = [shoreline_action.invoke_es_pod_usage_monitor,shoreline_action.invoke_scale_deployment]
}

resource "shoreline_file" "es_pod_usage_monitor" {
  name             = "es_pod_usage_monitor"
  input_file       = "${path.module}/data/es_pod_usage_monitor.sh"
  md5              = filemd5("${path.module}/data/es_pod_usage_monitor.sh")
  description      = "The Elasticsearch cluster may have insufficient resources such as CPU, memory, or storage space, leading to unassigned shards."
  destination_path = "/agent/scripts/es_pod_usage_monitor.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "scale_deployment" {
  name             = "scale_deployment"
  input_file       = "${path.module}/data/scale_deployment.sh"
  md5              = filemd5("${path.module}/data/scale_deployment.sh")
  description      = "Scale the Elasticsearch deployment to add more pods"
  destination_path = "/agent/scripts/scale_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_es_pod_usage_monitor" {
  name        = "invoke_es_pod_usage_monitor"
  description = "The Elasticsearch cluster may have insufficient resources such as CPU, memory, or storage space, leading to unassigned shards."
  command     = "`chmod +x /agent/scripts/es_pod_usage_monitor.sh && /agent/scripts/es_pod_usage_monitor.sh`"
  params      = ["ELASTICSEARCH_POD_NAME","ELASTICSEARCH_NAMESPACE","NAMESPACE"]
  file_deps   = ["es_pod_usage_monitor"]
  enabled     = true
  depends_on  = [shoreline_file.es_pod_usage_monitor]
}

resource "shoreline_action" "invoke_scale_deployment" {
  name        = "invoke_scale_deployment"
  description = "Scale the Elasticsearch deployment to add more pods"
  command     = "`chmod +x /agent/scripts/scale_deployment.sh && /agent/scripts/scale_deployment.sh`"
  params      = ["ELASTICSEARCH_DEPLOYMENT","NUMBER_OF_REPLICAS","NAMESPACE"]
  file_deps   = ["scale_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.scale_deployment]
}

