terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "agl-experiment"

    workspaces {
      prefix = "enterprise-data-"
    }
  }
}

module "global" {
  source = "./global"
}

module "environment" {
  source = "./environment"
  environment = var.TERRAFORM_WORKSPACE
}

provider "azurerm" {
  tenant_id       = module.global.tenant_id
  subscription_id = module.environment.subscription
  version         = "~> 1.0"
}

resource "azurerm_resource_group" "workspace-rg" {
  location = module.environment.location
  name     = "${module.global.prefix}-${var.TERRAFORM_WORKSPACE}"
  tags     = module.global.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.TERRAFORM_WORKSPACE}"
  resource_group_name = azurerm_resource_group.workspace-rg.name
  address_space       = [
    "10.0.0.0/16"
  ]
  location            = module.environment.location
  tags                = module.global.tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.TERRAFORM_WORKSPACE}"
  location            = module.environment.location
  resource_group_name = azurerm_resource_group.workspace-rg.name
}

resource "azurerm_subnet" "subs" {
  count                     = 2
  name                      = "sub-${count.index}"
  resource_group_name       = azurerm_resource_group.workspace-rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  address_prefix             = cidrsubnet(element(azurerm_virtual_network.vnet.address_space,0), 1, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  count = 2
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = element(azurerm_subnet.subs.*.id, count.index)
}

//resource "azurerm_storage_account" "sa" {
//  name = "${random_string.saname.result}sa00"
//  location = module.environment.location
//  resource_group_name = azurerm_resource_group.workspace-rg.name
//  account_replication_type = "LRS"
//  account_tier = "Standard"
//  network_rules {
//    default_action = "Deny"
//    ip_rules = concat(
//      local.whitelisted_ip_addresses,
//      list(
//        azurerm_subnet.subs.0.address_prefix,
//        azurerm_subnet.subs.1.address_prefix
//      )
//    )
//  }
//}

provider "random" {
  version = "~> 2.0"
}

resource "random_string" "saname" {
  length  = 5
  upper   = false
  special = false
}

locals {
  whitelisted_ip_addresses = [
    # see https://ips.zscaler.net/cenr for names
    "103.66.52.0/29",   # Microsoft Peering - Melbourne Equinix Cloud Exchange
    "103.66.53.0/29",   # Microsoft Peering - Sydney Equinix Cloud Exchange
    "146.178.91.0/24",  # PSDC AGL Data Centre
    "146.178.95.0/24",  # ESDC AGL Data Centre
    "165.225.98.0/24",  # Zscalar Melbourne
    "165.225.114.0/23", # Zscalar Sydney 3
    "165.225.226.0/23", # Zscalar Melbourne 2
    "175.45.116.0/24",  # Zscalar Sydney
    "165.225.106.0/23", # Zscalar Mumbai 2
  ]
}