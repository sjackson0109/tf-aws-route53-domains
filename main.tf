locals {
  special_tlds = ["be", "cl", "com.ar", "com.br", "es", "fi", "qa", "ru", "se", "sh"]
  domains_with_special_tld = [for d in keys(var.domains) : d if length([for t in local.special_tlds : endswith(d, ".${t}")]) > 0]
}

output "special_tld_warning" {
  value       = local.domains_with_special_tld
  description = "Domains that require special manual processing for owner changes. See README for details."
  # Note: Output will always be shown; check if the list is empty.
}
locals {
  # Precomputed: required country code for each domain
  required_country_code = {
    for domain in keys(var.domains) :
      domain => can(regex("\\.us$", domain)) ? "US" : can(regex("\\.ca$", domain)) ? "CA" : can(regex("\\.co\\.uk$", domain)) ? "GB" : can(regex("\\.uk$", domain)) ? "GB" : null
  }

  enforced_country_code = {
    for domain, v in var.domains :
      domain => local.required_country_code[domain] != null ? local.required_country_code[domain] : try(var.contacts[v.contacts.registrant_key].country_code, null)
  }

  # Precomputed: correct contact_type for each contact/domain/role
  computed_contact_type = {
    for domain, v in var.domains :
      domain => {
        for role in ["REGISTRANT", "ADMIN", "TECH"] :
          role =>
            length([
              for tld, allowed in local.tld_contact_type_overrides :
                tld if endswith(domain, tld) && !contains(allowed, var.contacts[v.contacts[role == "REGISTRANT" ? "registrant_key" : role == "ADMIN" ? "admin_key" : "tech_key"]].contact_type)
            ]) > 0
            ? "COMPANY"
            : var.contacts[v.contacts[role == "REGISTRANT" ? "registrant_key" : role == "ADMIN" ? "admin_key" : "tech_key"]].contact_type
      }
  }

  # Precomputed: required fields for each domain
  required_fields = {
    for domain in keys(var.domains) :
      domain => flatten([for tld, fields in local.tld_required_fields : fields if endswith(domain, tld)])
  }

  # Precomputed: is field required for each domain/field
  is_field_required = {
    for domain, fields in local.required_fields :
      domain => { for field in fields : field => true ... }
  }

  # Precomputed: required extra_params for each domain
  required_extra_params = {
    for domain in keys(var.domains) :
      domain => flatten([for tld, keys in local.tld_extra_params_required : keys if endswith(domain, tld)])
  }

  # Precomputed: is privacy forbidden for each domain
  privacy_forbidden = {
    for domain in keys(var.domains) :
      domain => length([for tld in local.tld_privacy_forbidden : tld if endswith(domain, tld)]) > 0
  }
  # Map of TLD-specific allowed contact types for ADMIN and TECH
  tld_contact_type_overrides = {
    ".uk"    = ["COMPANY", "ASSOCIATION", "PUBLIC_BODY"]
    ".co.uk" = ["COMPANY", "ASSOCIATION", "PUBLIC_BODY"]
    # Add more TLDs and their allowed types as needed
  }

  # Map of TLD-specific required fields (for contacts)
  tld_required_fields = {
    ".uk"    = ["organization_name", "extra_params"]
    ".co.uk" = ["organization_name", "extra_params"]
    # Add more TLDs and their required fields as needed
  }

  # Map of TLDs that do NOT allow privacy protection
  tld_privacy_forbidden = [
    # Example: ".us", ".in"
  ]

  # Map of TLDs that require extra_params (with example keys)
  tld_extra_params_required = {
    ".uk"    = ["UK_COMPANY_NUMBER", "UK_CONTACT_TYPE"]
    ".co.uk" = ["UK_COMPANY_NUMBER", "UK_CONTACT_TYPE"]
    # Add more TLDs and their required extra_params as needed
  }


  domains_registered_with_route53 = try({ for k, v in var.domains : k => v if try(v.registrar, false) == "route53" }, {})
}

################################################################
##    AWS LOGGED-IN-USER DATA                                 ##
################################################################
data "aws_caller_identity" "current" {}




################################################################
##    ROUTE 53 REGISTRAR                                          ##
################################################################
resource "aws_route53domains_registered_domain" "this" {
  for_each    = try(local.domains_registered_with_route53, {})
  domain_name = each.key

  # Registrant
  registrant_contact {
    address_line_1    = try(var.contacts[each.value.contacts.registrant_key].address_line_1, null)
    address_line_2    = try(var.contacts[each.value.contacts.registrant_key].address_line_2, null)
    city              = try(var.contacts[each.value.contacts.registrant_key].city, null)
    contact_type      = try(local.computed_contact_type[each.key]["REGISTRANT"], var.contacts[each.value.contacts.registrant_key].contact_type)
    country_code      = try(local.enforced_country_code[each.key], var.contacts[each.value.contacts.registrant_key].country_code)
    email             = try(var.contacts[each.value.contacts.registrant_key].email, null)
    extra_params      = contains(keys(local.is_field_required[each.key]), "extra_params") ? try(var.contacts[each.value.contacts.registrant_key].extra_params, null) : null
    fax               = try(var.contacts[each.value.contacts.registrant_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.registrant_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.registrant_key].last_name, null)
    organization_name = contains(keys(local.is_field_required[each.key]), "organization_name") ? try(var.contacts[each.value.contacts.registrant_key].organization_name, null) : null
    phone_number      = try(var.contacts[each.value.contacts.registrant_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.registrant_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.registrant_key].zip_code, null)
  }

  # Administrator
  admin_contact {
    address_line_1    = try(var.contacts[each.value.contacts.admin_key].address_line_1, null)
    address_line_2    = try(var.contacts[each.value.contacts.admin_key].address_line_2, null)
    city              = try(var.contacts[each.value.contacts.admin_key].city, null)
    contact_type      = try(local.computed_contact_type[each.key]["ADMIN"], var.contacts[each.value.contacts.admin_key].contact_type)
    country_code      = try(local.enforced_country_code[each.key], var.contacts[each.value.contacts.admin_key].country_code)
    email             = try(var.contacts[each.value.contacts.admin_key].email, null)
    extra_params      = contains(keys(local.is_field_required[each.key]), "extra_params") ? try(var.contacts[each.value.contacts.admin_key].extra_params, null) : null
    fax               = try(var.contacts[each.value.contacts.admin_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.admin_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.admin_key].last_name, null)
    organization_name = contains(keys(local.is_field_required[each.key]), "organization_name") ? try(var.contacts[each.value.contacts.admin_key].organization_name, null) : null
    phone_number      = try(var.contacts[each.value.contacts.admin_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.admin_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.admin_key].zip_code, null)
  }

  # Technical
  tech_contact {
    address_line_1    = try(var.contacts[each.value.contacts.tech_key].address_line_1, null)
    address_line_2    = try(var.contacts[each.value.contacts.tech_key].address_line_2, null)
    city              = try(var.contacts[each.value.contacts.tech_key].city, null)
    contact_type      = try(local.computed_contact_type[each.key]["TECH"], var.contacts[each.value.contacts.tech_key].contact_type)
    country_code      = try(local.enforced_country_code[each.key], var.contacts[each.value.contacts.tech_key].country_code)
    email             = try(var.contacts[each.value.contacts.tech_key].email, null)
    extra_params      = contains(keys(local.is_field_required[each.key]), "extra_params") ? try(var.contacts[each.value.contacts.tech_key].extra_params, null) : null
    fax               = try(var.contacts[each.value.contacts.tech_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.tech_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.tech_key].last_name, null)
    organization_name = contains(keys(local.is_field_required[each.key]), "organization_name") ? try(var.contacts[each.value.contacts.tech_key].organization_name, null) : null
    phone_number      = try(var.contacts[each.value.contacts.tech_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.tech_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.tech_key].zip_code, null)
  }

  # We can apply tagging at the global level, or at the individual domain level, or both/neither
  tags = {
    # ManagedBy = "Terraform"
  }

  # TODO: Consider modularizing this resource if managing many domains
  # Privacy - must be the same for all contact types, but forbidden for some TLDs
  admin_privacy      = try(local.privacy_forbidden[each.key], false) ? false : try(each.value.privacy, true)
  registrant_privacy = try(local.privacy_forbidden[each.key], false) ? false : try(each.value.privacy, true)
  tech_privacy       = try(local.privacy_forbidden[each.key], false) ? false : try(each.value.privacy, true)

  # Transfer Lock - you might need to mass unlock, useful
  transfer_lock = try(each.value.transfer_lock, true)

  # Auto Renew - need to dump some of the domains, simply stop renewing them...
  auto_renew = try(each.value.auto_renew, true)
  lifecycle {
    ignore_changes = [
      name_server,
      registrant_contact[0].phone_number,
      admin_contact[0].phone_number,
      tech_contact[0].phone_number
    ]
  }
}

output "notice" {
  value     = <<EOT
NOTICE: You may receive the following message:
│ Error: waiting for Route 53 Domains Domain ('mytestdomain.com') contacts update: timeout while waiting for state to become 'SUCCESSFUL' (last state: 'IN_PROGRESS', timeout: 30m0s)

Interpretation: Go and check the mailbox for 'verify this update was correct', then 'click on the verify link'.
Tip: Mine was flagged as quarantined on the way in, due to our DMARC policy.
EOT
  sensitive = false
}