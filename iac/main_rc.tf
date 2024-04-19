
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
      key                  = "terraform_rc.tfstate"
  }
}

############################################################
#Subscription
############################################################

provider "azurerm" {
    features {}
}

############################################################
#Data sources
############################################################

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

############################################################
# Variables
############################################################



############################################################
# Resource Group
############################################################

resource "azurerm_resource_group" "rg" {
    name     = "rg2${var.prefix}"
    location = var.azure_region
}

resource "time_sleep" "wait_60_seconds" {
    depends_on = [azurerm_resource_group.rg]
    create_duration = "60s"
}

#resource "azurerm_role_assignment" "role_assignment_github" {
  #scope                = azurerm_resource_group.rg.id
  #role_definition_name = "Owner"
  #principal_id         = var.githubworkflowaccount
  #depends_on           = [azurerm_resource_group.rg, time_sleep.wait_60_seconds]
#}


