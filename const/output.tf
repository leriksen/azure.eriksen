output "tags" {
    value = {
        BusinessOwner  = "AGL"
        TechnicalOwner = "DevOps"
        CostCentre     = "CCC001"
        CreatedBy      = "DevOps Angel"
        Project        = "OneCodeBase"
    }
}

output tenant_id {
    value = "74f9ac2f-c1d2-412f-8435-6e60efdad5e1"
}

output "subscriptions" {
    value = "${local.subscriptions}"
}

output prefix {
    value = "enterprise-data"
}

output "ws_sub_mapping" {
    value = "${local.ws_sub_mapping}"
}

output "workspace_rg_location_mapping" {
    value = {
        default = ""
        dev    = "australiasoutheast"
        prd    = "australiaeast"
  }
}
