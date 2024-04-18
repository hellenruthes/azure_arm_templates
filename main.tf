
############################################################
#Providers
############################################################

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.24.0"
        }
    }
}

############################################################
#Subscription
############################################################

provider "azurerm" {
    features {}
    alias           = "default"
    use_oidc        = true
    subscription_id = "91dd6738-03c5-4624-b049-6af68a429806"
    client_id       = "340afc1c-6ca1-49e6-b06b-e4246f381fcd"
    tenant_id       = "e59c14b6-f233-4142-9c75-12bfc17800a5"
}

############################################################
#Data sources
############################################################

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

############################################################
#Variables
############################################################

variable "azure_region" {
    description = "The Azure region to deploy resources"
    default     = "East US"
}

variable "short_name" {
    description = "The Azure region to deploy resources"
    default     = "tou"
}

variable "prefix" {
    description = "A prefix to add to all resources"
    default = "sandbox"
}

variable "another_user_object_id" {
    type = string
    description = "The object ID of another user to grant access to the Key Vault"
    default = "b8ff661d-b08b-4443-a9f6-3e6e709021e0"
}

locals {
    tags = {
        Environment = var.prefix
        Owner = "Data Platform Team"
        #project = "POC"
    }
}

############################################################
# Resource Group
############################################################

resource "azurerm_resource_group" "rg" {
    name     = "rg${var.prefix}"
    location = var.azure_region
}

############################################################
# Data Lake
############################################################

resource "azurerm_storage_account" "adls" {
    name                     = "${var.prefix}storage"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = var.azure_region
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Hot"
    tags                     = local.tags
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

#create storage container
resource "azurerm_storage_container" "adls_cont" {
    name                  = "datalake"
    storage_account_name  = azurerm_storage_account.adls.name
    container_access_type = "private"
}

resource "time_sleep" "role_assignment_sleep" {
  create_duration = "60s"

  triggers = {
    role_assignment = azurerm_role_assignment.role_assignment.id
  }
}

#create storage file system
resource "azurerm_storage_data_lake_gen2_filesystem" "adsl_fs" {
    name               = "${var.prefix}adlsfs"
    storage_account_id = azurerm_storage_account.adls.id
    depends_on         = [time_sleep.role_assignment_sleep]
    #depends_on         = [azurerm_storage_account.adls, azurerm_storage_container.adls_cont]

}

############################################################
#Synapse
############################################################

#create synapse workspace
resource "azurerm_synapse_workspace" "synapse" {
    name                                 = "${var.prefix}${var.short_name}synworkspace"
    resource_group_name                  = azurerm_resource_group.rg.name
    location                             = var.azure_region
    tags                                 = local.tags
    storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.adsl_fs.id
    sql_administrator_login              = "adminuser"
    sql_administrator_login_password     = "Password1234!"


    aad_admin {
        login           = "AzureAD Admin"
        object_id       = data.azurerm_client_config.current.object_id
        tenant_id       = data.azurerm_client_config.current.tenant_id
    }

    identity {
        type = "SystemAssigned"
    }
}


############################################################
#create synapse firewall
############################################################

resource "azurerm_synapse_firewall_rule" "synapse_firewall" {
    name                      = "AllowAll"
    synapse_workspace_id      = azurerm_synapse_workspace.synapse.id
    start_ip_address          = "0.0.0.0"
    end_ip_address            = "255.255.255.255"
}

############################################################
#synapse components - synapse role
############################################################
#wait 30 seconds for the workspace to be created

resource "time_sleep" "wait_x_seconds" {
    depends_on = [azurerm_synapse_workspace.synapse,
                  azurerm_synapse_firewall_rule.synapse_firewall]
    create_duration = "60s"
}

# create synapse role
resource "azurerm_synapse_role_assignment" "synapse_role" {
    synapse_workspace_id = azurerm_synapse_workspace.synapse.id
    role_name            = "Synapse SQL Administrator"
    principal_id         = var.another_user_object_id

    depends_on = [azurerm_synapse_workspace.synapse,
                  azurerm_synapse_firewall_rule.synapse_firewall,
                  time_sleep.wait_x_seconds]
}

############################################################
#create synapse components - linked services ADLS
############################################################
#get data lake
data "azurerm_storage_account" "adls" {
    name                = azurerm_storage_account.adls.name
    resource_group_name = azurerm_resource_group.rg.name
}

# add linked service to synapse
resource "azurerm_synapse_linked_service" "synapse_ls_adls" {
    name                    = "LinkedService_ADLS"
    synapse_workspace_id    = azurerm_synapse_workspace.synapse.id
    type                    = "AzureBlobStorage"
    type_properties_json    = <<JSON
    {
        "connectionString": "${data.azurerm_storage_account.adls.primary_connection_string}"
    }
    JSON

    depends_on              = [azurerm_synapse_workspace.synapse,
                              azurerm_synapse_role_assignment.synapse_role]
}

#assing synapse mssi access: ADLS
resource "azurerm_role_assignment" "synapse_msi_adls" {
    scope                = data.azurerm_storage_account.adls.id
    role_definition_name = "Storage Blob Data Owner"
    principal_id         = azurerm_synapse_workspace.synapse.identity.0.principal_id
}

############################################################
#Synapse Config - Spark Pool
############################################################

#create spark pool

resource "azurerm_synapse_spark_pool" "synapse_spark_pool" {
    name                       = "${var.prefix}synspark"
    synapse_workspace_id       = azurerm_synapse_workspace.synapse.id
    node_size_family           = "MemoryOptimized"
    node_size                  = "Small"
    cache_size                 = 100

    auto_scale {
        max_node_count  = 10
        min_node_count  = 3
    }

    auto_pause {
        delay_in_minutes   = 10
    }

    #library_requirement {
        #content = <<EOF
        #EOF
    #filename = "requirements.txt"
    #}
    
    spark_config {
        content = <<EOF
        spark.shuffle.spill true
        EOF
        filename = "config.txt"
    }
    tags = local.tags
}


############################################################
#Synapse Config - dedicated sql pool
############################################################

############################################################
# output
############################################################

output "resource_group_name"{
    value = azurerm_resource_group.rg.name
}

output "azure_region" {
    value = azurerm_resource_group.rg.location
}

output "adls_name" {
    value = azurerm_storage_account.adls.name
}

output "synapse_name" {
    value = azurerm_synapse_workspace.synapse.name
}
