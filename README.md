## Preface

Author: Simon Jackson (sjackson0109)
Version:        1.0.1
Date: 09/01/2024

## Objective
Mass update the AWS Route53 registrar WHOIS contact details for all the domains, a customer had registered with them. Figured this would be extremely useful to share with the world. 

## TLD requirements
Of course TLD requirements must be met. I can't consider listing them all here. AWS does a good job of that. Check [this](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-update-contacts.html) article out if you are struggling.
For some DENIED messages; there are TLDs that require a signed/stamped `Change of Domain Ownership` form to be completed. See [here](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-update-contacts.html#domain-update-contacts-domain-ownership-form).

## Addressing Concerns
Terraform can be very destructive if not fully understood. 
Recommend you read this article on the [terraform registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53domains_registered_domain) before proceeding.

**Automatic Domain Management:**
With the `aws_route53domains_registered_domain` resource, Terraform will automatically detect and manage pre-existing domains in your AWS account when you define them in your configuration and run `terraform apply`. Manual use of `terraform import` is **not required** for these resources. Terraform will pull the current state from AWS and allow you to manage updates via your configuration files.

**Destruction Warning:**
If you perform a `terraform destroy` command, the state-file is the ONLY place the domains are removed. They are not purged from your AWS Route53 account!

## Requirements for this project
You will need the following:
- IAM user with a CLI Access-Key, and Secret
- Either one of these pre-assigned managed policies `AdministratorAccess`, `AmazonRoute53FullAccess` or `AmazonRoute53DomainsFullAccess`

## Step-by-step Instructions
1. Download this repository to your local workstation
2. Install terraform
3. Launch a BASH or PowerShell terminal. and set 3x variables:
 <br> - $env:AWS_ACCESS_KEY_ID="<KEY-GOES-HERE>"
 <br> - $env:AWS_SECRET_ACCESS_KEY="<SECRET-VALUE-GOES-HERE>"
 <br> - $env:AWS_REGION="us-east-1"

4. Initialise Terraform using `terraform init`
5. Plan for the build, using `terraform plan`. The following output should be visible:
```Plan: 1 to add, 0 to change, 0 to destroy.```
6. Apply all changes using `terraform apply -auto-approve`. The following output should be visible:
```Apply complete! Resources: 1 added, 0 changed, 0 destroyed.```

## Usage Example

```
module "route53_domains" {

  source   = "./"
  domains  = var.domains
  contacts = var.contacts
}
```

## Variables

### `domains`
Type: `map(object)`

Each key is a domain name (e.g., `mytestdomain.com`). Value is an object with:
  - `registrar` (string, optional): Registrar name (e.g., `route53`).
  - `contacts` (object, required):
      - `registrant_key` (string, required): Key referencing a contact in `contacts` map.
      - `admin_key` (string, required): Key referencing a contact in `contacts` map.
      - `tech_key` (string, required): Key referencing a contact in `contacts` map.
  - `privacy` (bool, optional): Enable privacy protection.
  - `transfer_lock` (bool, optional): Enable transfer lock.
  - `auto_renew` (bool, optional): Enable auto-renewal.
  - Any other domain-specific fields as needed.

### `contacts`
Type: `map(object)`

Each key is a contact reference (string or int). Value is an object with:
  - `address_line_1` (string, required): First line of address.
  - `address_line_2` (string, optional): Second line of address.
  - `city` (string, required): City.
  - `contact_type` (string, required): One of `PERSON`, `COMPANY`, `ASSOCIATION`, `PUBLIC_BODY`, `RESELLER`.
  - `country_code` (string, required): 2-letter country code (e.g., `GB`).
  - `email` (string, required): Email address.
  - `extra_params` (map(string), optional): Extra TLD-specific parameters.
  - `fax` (string, optional): Fax number.
  - `first_name` (string, required): First name.
  - `last_name` (string, required): Last name.
  - `organization_name` (string, optional): Organization name (for non-PERSON types).
  - `phone_number` (string, required): E.164 format (e.g., `+44.1234567890`).
  - `state` (string, optional): State or province.
  - `zip_code` (string, required): Postal code.

## Example: Using a Nested var-file

Create a file like `clients/goodshape.tfvars`:
```hcl
contacts = {
  "1" = {
    address_line_1 = "28 Clarendon Road"
    city           = "Watford"
    contact_type   = "COMPANY"
    country_code   = "GB"
    email          = "domains@goodshape.com"
    extra_params = {
      UK_COMPANY_NUMBER = "05297929"
      UK_CONTACT_TYPE   = "LTD"
    }
    first_name        = "Jing"
    last_name         = "Tang"
    organization_name = "GoodShape UK Ltd"
    phone_number      = "+44.3454565730"
    zip_code          = "WD17 1JJ"
  }
  # ... more contacts ...
}

domains = {
  "mytestdomain.com" = {
    registrar     = "route53"
    auto_renew    = true
    transfer_lock = true
    contacts = {
      registrant_key = "1"
      admin_key      = "2"
      tech_key       = "3"
    }
  }
  # ... more domains ...
}
```
Then run:
```bash
terraform apply --var-file=./clients/goodshape.tfvars
```

## Outputs
- `notice`: Guidance for verifying contact updates in your email inbox.

## Troubleshooting

- Ensure all required contact fields are provided and valid. See variable validation errors for details.
- Check AWS documentation for TLD-specific requirements and required extra_params for your TLD.
- Use `terraform plan` to preview changes before applying.
- If you see errors about contact types, country codes, or phone numbers, check your `contacts` map for correct values and formats.
- For errors like `timeout while waiting for state to become 'SUCCESSFUL'`, check your email for verification links from AWS and confirm them promptly.
- If you get `Error: Invalid value for input variable`, review your `.tfvars` file for missing or mis-typed fields.
- For issues with domain import or state, remember that `terraform destroy` does not delete domains from AWS, only from state.

## Security
- Do not commit `*.tfvars` or state files to version control.
- Use remote state for team collaboration and backup.

# Recommendations

## TLD-Specific Requirements

| TLD         | Special Manual Processing Required? | Notes                                                                 |
|-------------|-------------------------------------|-----------------------------------------------------------------------|
| .be, .cl, .com.ar, .com.br, .es, .fi, .qa, .ru, .se, .sh | Yes                                 | Requires AWS Support case and/or registry form for owner changes      |
| .tech, .ltd, .net, .org, .info, .biz, .tv, .global, others | No                                  | Standard AWS/Terraform automation applies; email verification may occur |

**.tech, .ltd, .net, .org, and similar TLDs:**

- You can update contact and ownership information for these TLDs programmatically using Terraform and AWS Route53.
- No AWS Support case or special form is required for owner/contact changes.
- AWS may require email verification for some changes (follow the verification link sent to the registrant's email).
- If your TLD requires specific extra parameters, add them in the `extra_params` map for the contact in your `.tfvars` file.

**For TLDs that require special processing:**
- See the AWS documentation and the table above. These TLDs require manual steps for owner changes and cannot be fully automated.

For more details, see:
- [AWS Route53: Updating contact information and ownership for a domain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-update-contacts.html)
- [AWS Route53: TLDs that require special processing to change the owner](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-update-contacts.html#domain-update-contacts-domain-ownership-form)
I recommend doing this for ONE domain first, for every set of unique contact details you need to set; then doing the rest after you confirmed that is successful. Why?
Because of the following Error:
```
│ Error: waiting for Route 53 Domains Domain ("mytestdomain.com") contacts update: timeout while waiting for state to become 'SUCCESSFUL' (last state: 'IN_PROGRESS', timeout: 30m0s)
```
How to fix this: simply go to the mailbox of the contact, and click on the verify contact details link.


# Terraform state (example):
aws_route53domains_registered_domain.this["mytestdomain.com"]