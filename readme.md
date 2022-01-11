# Azure Virtual Desktop - Hostpool Token
This module is designed to be used with the Host module and provides the Hostpool Registration Token allowing a newly provisioned VM to be added to the Hostpool. This module should be deprecated or updated once the AzureRM provider is updated to include `azurerm_virtual_desktop_host_pool_registration_info`.

This module leverages the Data.External to execute a Powershell script included in this repository. This script will check to see if there is an existing token that can be used and if not, it will create a new token. Here is an example of how to implement the module:
```terraform
module "hostpool_token" {
    source                  = "git::https://github.com/idexcorp-cit/az-avd-hostpool-token-module.git?ref=v0.1.0"

    hostpool_resource_group = module.hostpool.resource_group_name
    hostpool_name           = module.hostpool.hostpool_name
    token_valid_hours       = 3
}

module "host" {
    source                  = "https://github.com/idexcorp-cit/az-avd-personal-host-module.git?ref=v0.1.0"

    for_each                = var.avd_users

    resource_prefix         = "${var.resource_prefix}-avd-${each.key}"
    resource_group_name     = azurerm_resource_group.avd_host[each.key].name
    location                = azurerm_resource_group.avd_host[each.key].location
    hostpool_name           = module.hostpool.hostpool_name
    hostpool_token          = module.hostpool_token.token
    hostpool_resource_group = module.hostpool.resource_group_name
    dag_id                  = module.hostpool.dag_id
    host_subnet_id          = var.subnet_id != null ? var.subnet_id : azurerm_subnet.avd["subnet"].id
    host_encryption_at_host = true
    
    adds_domain_join_upn    = var.adds_domain_join_upn
    adds_domain_join_pass   = var.adds_domain_join_pass
    adds_domain_join_name   = var.adds_domain_join_name
    adds_ou_path            = var.adds_ou_path

    assigned_user       = lookup(each.value, "user")
    host_computer_name  = lookup(each.value, "computer_name_override", "avd${substr(var.department_shortname, 0, 3)}${substr(each.key, 0, 7)}")
    host_index          = lookup(each.value, "index")
    host_size           = lookup(each.value, "size", "Standard_D2s_v4")
    host_disk_size      = lookup(each.value, "disk_size", "256")
    host_timezone       = lookup(each.value, "timezone", "Central Standard Time")
    host_image_offer    = lookup(each.value, "image_offer", "Windows-10")
    host_image_sku      = lookup(each.value, "image_sku", "win10-21h2-ent")
    host_shutdown_time  = lookup(each.value, "shutdown_time", null)
}
```
This module assumes that the following items:
- Environment variables are set
    - `ARM_SUBSCRIPTION_ID`
    - `ARM_TENANT_ID`
    - `ARM_CLIENT_ID`
    - `ARM_CLIENT_SECRET`
- Powershell 6+ is installed and can install Az.Accounts and Az.DesktopVirtualization modules.