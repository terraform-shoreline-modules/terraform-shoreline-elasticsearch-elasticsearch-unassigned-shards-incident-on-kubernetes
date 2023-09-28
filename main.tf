terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "elasticsearch_unassigned_shards_incident_on_kubernetes" {
  source    = "./modules/elasticsearch_unassigned_shards_incident_on_kubernetes"

  providers = {
    shoreline = shoreline
  }
}