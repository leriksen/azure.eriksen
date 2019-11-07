terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "agl-experiment"

    workspaces {
      prefix = "enterprise-data-"
    }
  }
}

module "const" {
  source = "../const"
}


provider "azurerm" {
  tenant_id       = "${module.const.tenant_id}"
  subscription_id = "${module.const.ws_sub_mapping[var.TERRAFORM_WORKSPACE]}"
  version         = "~> 1.36.0"
}

resource "azurerm_resource_group" "workspace-rg" {
  location = "${module.const.workspace_rg_location_mapping[var.TERRAFORM_WORKSPACE]}"
  name     = "${module.const.prefix}-${var.TERRAFORM_WORKSPACE}"
  tags     = "${module.const.tags}"
}
