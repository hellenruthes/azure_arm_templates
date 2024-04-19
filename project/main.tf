terraform {
    required_version = ">= 0.12"
    
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 3.42.0, < 4.0.0"
        }
    }

     backend "azurerm" {
      #resource_group_name  = "tfstate"
      #storage_account_name = "tfstateo9e52"
      #container_name       = "tfstate"
      #key                  = "terraform_rc.tfstate"
  }
}
 