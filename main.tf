locals {
  # Couple of queries to shrink the data-set in tfvars > time-saver
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
    contact_type      = try(var.contacts[each.value.contacts.registrant_key].contact_type, null)
    country_code      = try(var.contacts[each.value.contacts.registrant_key].country_code, null)
    email             = try(var.contacts[each.value.contacts.registrant_key].email, null)
    extra_params      = try(var.contacts[each.value.contacts.registrant_key].extra_params, null)
    fax               = try(var.contacts[each.value.contacts.registrant_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.registrant_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.registrant_key].last_name, null)
    organization_name = try(var.contacts[each.value.contacts.registrant_key].organization_name, null)
    phone_number      = try(var.contacts[each.value.contacts.registrant_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.registrant_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.registrant_key].zip_code, null)
  }

  # Administrator
  admin_contact {
    address_line_1    = try(var.contacts[each.value.contacts.admin_key].address_line_1, null)
    address_line_2    = try(var.contacts[each.value.contacts.admin_key].address_line_2, null)
    city              = try(var.contacts[each.value.contacts.admin_key].city, null)
    contact_type      = try(var.contacts[each.value.contacts.admin_key].contact_type, null)
    country_code      = try(var.contacts[each.value.contacts.admin_key].country_code, null)
    email             = try(var.contacts[each.value.contacts.admin_key].email, null)
    extra_params      = try(var.contacts[each.value.contacts.admin_key].extra_params, null)
    fax               = try(var.contacts[each.value.contacts.admin_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.admin_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.admin_key].last_name, null)
    organization_name = try(var.contacts[each.value.contacts.admin_key].organization_name, null)
    phone_number      = try(var.contacts[each.value.contacts.admin_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.admin_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.admin_key].zip_code, null)
  }
  # Technical
  tech_contact {
    address_line_1    = try(var.contacts[each.value.contacts.tech_key].address_line_1, null)
    address_line_2    = try(var.contacts[each.value.contacts.tech_key].address_line_2, null)
    city              = try(var.contacts[each.value.contacts.tech_key].city, null)
    contact_type      = try(var.contacts[each.value.contacts.tech_key].contact_type, null)
    country_code      = try(var.contacts[each.value.contacts.tech_key].country_code, null)
    email             = try(var.contacts[each.value.contacts.tech_key].email, null)
    extra_params      = try(var.contacts[each.value.contacts.tech_key].extra_params, null)
    fax               = try(var.contacts[each.value.contacts.tech_key].fax, null)
    first_name        = try(var.contacts[each.value.contacts.tech_key].first_name, null)
    last_name         = try(var.contacts[each.value.contacts.tech_key].last_name, null)
    organization_name = try(var.contacts[each.value.contacts.tech_key].organization_name, null)
    phone_number      = try(var.contacts[each.value.contacts.tech_key].phone_number, null)
    state             = try(var.contacts[each.value.contacts.tech_key].state, null)
    zip_code          = try(var.contacts[each.value.contacts.tech_key].zip_code, null)
  }
  # Privacy - must be the same for all contact types
  admin_privacy      = try(each.value.privacy, true)
  registrant_privacy = try(each.value.privacy, true)
  tech_privacy       = try(each.value.privacy, true)

  # Transfer Lock - you might need to mass unlock, useful
  transfer_lock = try(each.value.transfer_lock, true)

  # Auto Renew - need to dump some of the domains, simply stop renewing them...
  auto_renew = try(each.value.auto_renew, true)
}

output "notice" {
  value = <<EOT
NOTICE: You may receive the following message:
│ Error: waiting for Route 53 Domains Domain ('mytestdomain.com') contacts update: timeout while waiting for state to become 'SUCCESSFUL' (last state: 'IN_PROGRESS', timeout: 30m0s)

Interpretation: Go and check the mailbox for 'verify this update was correct', then 'click on the verify link'.
Tip: Mine was flagged as quarantined on the way in, due to our DMARC policy.
EOT
}