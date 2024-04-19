
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

variable "azure_region" {
    description = "The Azure region to deploy resources"
    default     = "East US"
}

variable "resource_group_name_prefix" {
    default     = "rgsandbox"
}

variable "short_name" {
    description = "The Azure region to deploy resources"
    default     = "tou"
}

variable "prefix" {
    description = "A prefix to add to all resources"
    default = "test"
}

variable "another_user_object_id" {
    type = string
    description = "The object ID of another user to grant access to the Key Vault"
    default = "b8ff661d-b08b-4443-a9f6-3e6e709021e0"
}

variable "githubworkflowaccount" {
    type = string
    description = "The object ID of another user to grant access to the Key Vault"
    default = "413ed49c-aeb7-4e8e-82d8-46ef68768198"
}

locals {
    tags = {
        Environment = var.prefix
        Owner = "Data Platform Team"
        Project = "POC"
    }
}

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


