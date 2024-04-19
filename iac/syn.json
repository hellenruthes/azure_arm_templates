
############################################################
#Providers
############################################################


terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 3.42.0, < 4.0.0"
        }
    }

     backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstateo9e52"
      container_name       = "tfstate"
      key                  = "terraform_synapse.tfstate"
  }
}

############################################################
#Subscription
############################################################

provider "azurerm" {
    features {}
    #subscription_id = "91dd6738-03c5-4624-b049-6af68a429806"
    #client_id       = "340afc1c-6ca1-49e6-b06b-e4246f381fcd"
    #tenant_id       = "e59c14b6-f233-4142-9c75-12bfc17800a5"

}
############################################################
#Data sources
############################################################

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

############################################################
#Variables
############################################################



############################################################
# Resource Group
############################################################

resource "azurerm_resource_group" "rg" {
    name     = "rg${var.prefix}"
    location = var.azure_region
}

resource "time_sleep" "wait_60_seconds" {
    depends_on = [azurerm_resource_group.rg]
    create_duration = "60s"
}

resource "azurerm_role_assignment" "role_assignment_github" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = var.githubworkflowaccount
  depends_on           = [azurerm_resource_group.rg, time_sleep.wait_60_seconds]
}

############################################################
# Data Lake
############################################################
