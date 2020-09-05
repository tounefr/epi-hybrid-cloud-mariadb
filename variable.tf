variable "region" {
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

variable "inventory-path" {
  type = string
  default = "./inventory"
}
