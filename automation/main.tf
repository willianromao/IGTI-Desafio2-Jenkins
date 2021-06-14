terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "jenkins-lab"
  location = "westus2"
  tags = {
    Environment = "LAB"
  }
}

resource "azurerm_kubernetes_cluster" "IGTI" {
  name                = "IGTI-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "igti-k8s-devops"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ms"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "LAB"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.IGTI.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.IGTI.kube_config_raw
  sensitive = true
}
