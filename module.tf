
module "myazure_westeurope" {
  source = "./myazure"
  zone_key = "westeurope"
  zone_label = "West Europe"
  serverid_prefix = 1
}

module "myazure_northeurope" {
  source = "./myazure"
  zone_key = "northeurope"
  zone_label = "North Europe"
  serverid_prefix = 2
}

module "myazure_francecentral" {
  source = "./myazure"
  zone_key = "francecentral"
  zone_label = "France Central"
  serverid_prefix = 3
}

