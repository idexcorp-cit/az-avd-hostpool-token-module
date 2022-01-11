data "azurerm_client_config" "current" {}

data "external" "token" {
    program = ["pwsh", "${path.module}/get-token.ps1"]

    query   = {
        resourceGroupName   = var.hostpool_resource_group
        hostPoolName        = var.hostpool_name
        subscriptionId      = data.azurerm_client_config.current.subscription_id
        tokenValidHours     = var.token_valid_hours
    }
}

output token {
    value = data.external.token.result.token
}

output expiration_time {
    value = data.external.token.result.expiration_time
}