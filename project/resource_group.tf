
terraform{
    required_version = ">= 0.12"
}

provider "azurerm" {
    features {}
}


data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}



resource "azurerm_resource_group" "rg" {
    name     = "rgdev${var.prefix}"
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

############################################################