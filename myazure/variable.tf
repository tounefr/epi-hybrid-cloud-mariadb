variable "region" {
  type = string
  default = ""
}

variable "zone_key" {
  type = string
  default = ""
}

variable "zone_label" {
  type = string
  default = ""
}

variable "resource_name" {
  type = string
  default = ""
}

variable "instances_count" {
  type = string
  default = 1
}

variable "serverid_prefix" {
  type = string
  default = ""
}

variable "inventory-path" {
  type = string
  default = "./inventory"
}
