variable "pingdirectory_console_base_url" {
  type    = string
  default = "https://localhost:8443"
}

variable "pingdirectory_ldap_host" {
  type    = string
  default = null
}

variable "pingdirectory_ldap_port" {
  type    = number
  default = null
}