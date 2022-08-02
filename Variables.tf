variable "resource_group_name" {
  description = "Name for the resource group"
  type        = string
  default     = "Azure_Sentinel_Lab"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"

}

variable "virtual_network_name" {
  description = "Name for the VNet"
  type        = string
  default     = "Azure_Sentinel_VNet"

}

variable "subnet_name" {
  description = "Name for the Subnet"
  type        = string
  default     = "Azure_Sentinel_Subnet"

}

variable "security_group_name" {
  description = "Name for SG"
  type        = string
  default     = "Azure_Sentinel_SG"

}