variable "domains" {
  type = map(object({
    registrar = optional(string)
    contacts  = object({
      registrant_key = string
      admin_key      = string
      tech_key       = string
    })
    privacy        = optional(bool)
    transfer_lock  = optional(bool)
    auto_renew     = optional(bool)
    # Add other domain-specific fields as needed
  }))
  description = "Map of domain configurations. Each key is a domain name."
  default = {}
  validation {
    condition     = alltrue([for k, v in var.domains : can(regex("^[a-zA-Z0-9.-]+$", k))])
    error_message = "All domain names must be valid DNS names (letters, numbers, dashes, and dots only)."
  }
  validation {
    condition     = alltrue([for k, v in var.domains :
      length(trimspace(v.contacts.registrant_key)) > 0 &&
      length(trimspace(v.contacts.admin_key)) > 0 &&
      length(trimspace(v.contacts.tech_key)) > 0
    ])
    error_message = "Each domain must specify registrant_key, admin_key, and tech_key in contacts."
  }
}

variable "contacts" {
  type = map(object({
    address_line_1    = string
    address_line_2    = optional(string)
    city              = string
    contact_type      = string
    country_code      = string
    email             = string
    extra_params      = optional(map(string))
    fax               = optional(string)
    first_name        = string
    last_name         = string
    organization_name = optional(string)
    phone_number      = string
    state             = optional(string)
    zip_code          = string
  }))
  description = "Map of contact details keyed by contact type."
  default = {}
  validation {
    condition     = alltrue([
      for k, v in var.contacts :
        length(trimspace(v.first_name)) > 0 &&
        length(trimspace(v.last_name)) > 0 &&
        can(regex("^[A-Z]{2}$", v.country_code)) &&
        can(regex("^[A-Za-z0-9 .,'-]+$", v.address_line_1)) &&
        length(trimspace(v.city)) > 0 &&
        can(regex("^[A-Z]{2}$", v.country_code)) &&
  can(regex("^[^@ \t]+@[^@ \t]+\\.[^@ \t]+$", v.email)) &&
            can(regex("^\\+[0-9]{1,3}\\.[0-9]{4,}$", v.phone_number)) &&
        length(trimspace(v.zip_code)) > 0 &&
        contains(["PERSON", "COMPANY", "ASSOCIATION", "PUBLIC_BODY", "RESELLER"], v.contact_type)
    ])
    error_message = "Each contact must have valid first/last name, address, city, 2-letter country code, email, E.164 phone number, zip code, and allowed contact_type (PERSON, COMPANY, ASSOCIATION, PUBLIC_BODY, RESELLER)."
  }
}