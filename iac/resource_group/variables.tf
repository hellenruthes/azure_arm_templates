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
    default = "sandbox"
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
        #project = "POC"
    }
}
