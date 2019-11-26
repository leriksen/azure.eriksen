locals {
    subscriptions = {
        default = ""
        staging = "40371827-837f-4329-a4c1-1000a8a29725"
        production = "d4a41ee3-311b-4c4e-925f-efe88c259051"
    }

    env_sub_mapping = {
        default = ""
        dev = "${local.subscriptions["staging"]}"
        prd = "${local.subscriptions["production"]}"
    }

    locations = {
        default = ""
        dev = "australiasoutheast"
        prd = "australiaeast"
    }
}