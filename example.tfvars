contacts = {
  0 = {
    address_line_1 = "Buckingham Palace"         # (Optional) First line of the contact's address.
    address_line_2 = null                        # (Optional) Second line of contact's address if any.
    city           = "London"                    # (Optional) The city of the contact's address.
    contact_type   = "COMPANY"                   # (Optional) Indicates whether the contact is a person company association or public organization.
    #                                            Options: PERSON | COMPANY | ASSOCIATION | PUBLIC_BODY | RESELLER
    #                                            More reading: https://docs.aws.amazon.com/cli/latest/reference/route53domains/update-domain-contact.html
    country_code      = "GB"                     # (Optional) Code for the country of the contact's address. See the AWS API documentation for valid values.
    email             = "whois@mytestdomain.com" # (Optional) Email address of the contact.
    extra_params      = null                     # (Optional) A key-value map of parameters required by certain top-level domains.
    fax               = null                     # (Optional) Fax number of the contact. Phone number must be specified in the format "+[country dialing code].[number including any area code]".
    first_name        = "His Majesty"            # (Optional) First name of contact.
    last_name         = "The King"               # (Optional) Last name of contact.
    organization_name = "My Test Domain Company" # (Optional) Name of the organization for contact types other than PERSON.
    phone_number      = "+44.0000000000"         # (Optional) The phone number of the contact. Phone number must be specified in the format "+[country dialing code].[number including any area code]".
    state             = null                     # (Optional) The state or province of the contact's city.
    zip_code          = "SW1A 1AA"               # (Optional) The zip or postal code of the contact's address.
  },
  1 = {
    address_line_1    = "Buckingham Palace"      # (Optional) First line of the contact's address.
    address_line_2    = null                     # (Optional) Second line of contact's address if any.
    city              = "London"                 # (Optional) The city of the contact's address.
    contact_type      = "PERSON"                 # (Optional) Indicates whether the contact is a person company association or public organization.
    country_code      = "GB"                     # (Optional) Code for the country of the contact's address. See the AWS API documentation for valid values.
    email             = "whois@mytestdomain.com" # (Optional) Email address of the contact.
    extra_params      = null                     # (Optional) A key-value map of parameters required by certain top-level domains.
    fax               = null                     # (Optional) Fax number of the contact. Phone number must be specified in the format "+[country dialing code].[number including any area code]".
    first_name        = "King"                   # (Optional) First name of contact.
    last_name         = "Charles III"            # (Optional) Last name of contact.
    organization_name = "My Test Domain Company" # (Optional) Name of the organization for contact types other than PERSON.
    phone_number      = "+44.0000000000"         # (Optional) The phone number of the contact. Phone number must be specified in the format "+[country dialing code].[number including any area code]".
    state             = null                     # (Optional) The state or province of the contact's city.
    zip_code          = "SW1A 1AA"               # (Optional) The zip or postal code of the contact's address.
  }
}

domains = {
  "mytestdomain.com" = {
    registrar     = "route53"
    auto_renew    = true
    transfer_lock = true
    contacts = {
      registrant_key = "0" # must set contact_type = "COMPANY" 
      admin_key      = "1"
      tech_key       = "1"
    }
  }
}