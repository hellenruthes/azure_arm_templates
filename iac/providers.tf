
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 3.42.0, < 4.0.0"
        }
    }
    databricks = {
      source = "databrickslabs/databricks"
      version = "0.2.5"
    }

     backend "azurerm" {
      #resource_group_name  = "tfstate"
      #storage_account_name = "tfstateo9e52"
      #container_name       = "tfstate"
      #key                  = "terraform_rc.tfstate"
  }
}