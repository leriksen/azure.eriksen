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
  location = "module.environment.location
  name     = "${module.global.prefix}-${var.TERRAFORM_WORKSPACE}
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
  address_prefix            = cidrsubnet(element(azurerm_virtual_network.vnet.address_space,0), 1, count.index)
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