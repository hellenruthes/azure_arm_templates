resource "azurerm_resource_group" "function-group"{
    name = "function-group"
    location = var.azure_region
}

resource "azurerm_storage_account" "function-group-storage-acc"{
    name = "functiongroupstorageacc"
    location = var.azure_region
    resource_group_name = "rg2test"
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_service_plan "function-service-plan"{
    name = "function-service-plan"
    location = var.azure_region
    resource_group_name = "rg2test"
    os_type = "Linux"
    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "function-app"{
    name = "function-app"
    location = var.azure_region
    resource_group_name = "rg2test"
    app_service_plan_id = azurerm_service_plan.function-service-plan.id
    storage_account_name = azurerm_storage_account.function-group-storage-acc.name
    storage_account_access_key = azurerm_storage_account.function-group-storage-acc.primary_access_key
    version = "~4"
    app_settings {
        FUNCTIONS_WORKER_RUNTIME = "python"
    }

    site_config {
        linux_fx_version = "python|3.9"
    }
}