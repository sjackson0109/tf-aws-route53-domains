## Preface

- Author: Simon Jackson (sjackson0109)
- Version: 1.0.2
- Date Created: 09/01/2024
- Date Modified: 27/09/2025

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

    ```bash
    $env:AWS_ACCESS_KEY_ID="<KEY-GOES-HERE>"
    $env:AWS_SECRET_ACCESS_KEY="<SECRET-VALUE-GOES-HERE>"
    $env:AWS_REGION="us-east-1"
    ```


4. **Initialise Terraform**
  
    Run:
  
    ```bash
    terraform init
    ```
  
    This will download the required provider plugins and set up the backend.

5. **Plan the deployment**

    To see what changes will be made, run:
    
    ```bash
    terraform plan --var-file=./examples/example.tfvars
    ```
    
    Replace the file path with your own `.tfvars` file as needed. This command will show you a summary of what Terraform will add, change, or destroy. No changes are made at this stage.

6. **Apply the changes**

    To make the changes, run:
    
    ```bash
    terraform apply --var-file=./examples/example.tfvars
    ```
    
    You will be prompted to confirm. To skip the prompt, add `-auto-approve`.

    Example output:
    
    ```
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```

## Terraform Outputs

After running `terraform apply`, you may see outputs such as:

- `notice`: Guidance for verifying contact updates in your email inbox. This will remind you to check for verification emails from AWS and confirm any required changes.
- `special_tld_warning`: (If present) Lists domains that require special manual processing for owner changes. This is informational and helps you identify domains that may need AWS Support intervention.

These outputs are informational and do not affect your infrastructure.

## Module Usage Example

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

Each key is a domain name (e.g., `mytestdomain.com`). Value is an object with the following fields:

| Field           | Type     | Required? | Description                                                      |
|-----------------|----------|-----------|------------------------------------------------------------------|
| registrar       | string   | Optional  | Registrar name (e.g., `route53`)                                 |
| contacts        | object   | Required  | See below; maps contact roles to contact keys                    |
| ├─ registrant_key | string | Required  | Key referencing a contact in `contacts` map                      |
| ├─ admin_key      | string | Required  | Key referencing a contact in `contacts` map                      |
| └─ tech_key       | string | Required  | Key referencing a contact in `contacts` map                      |
| privacy         | bool     | Optional  | Enable privacy protection                                        |
| transfer_lock   | bool     | Optional  | Enable transfer lock                                             |
| auto_renew      | bool     | Optional  | Enable auto-renewal                                              |
| ...             | any      | Optional  | Any other domain-specific fields as needed                       |

### `contacts`
Type: `map(object)`

Each key is a contact reference (string or int). Value is an object with the following fields:

| Field             | Type          | Required? | Description                                                      |
|-------------------|---------------|-----------|------------------------------------------------------------------|
| address_line_1    | string        | Required  | First line of address                                            |
| address_line_2    | string        | Optional  | Second line of address                                           |
| city              | string        | Required  | City                                                            |
| contact_type      | string        | Required  | One of `PERSON`, `COMPANY`, `ASSOCIATION`, `PUBLIC_BODY`, `RESELLER` |
| country_code      | string        | Required  | 2-letter country code (e.g., `GB`)                               |
| email             | string        | Required  | Email address                                                    |
| extra_params      | map(string)   | Optional  | Extra TLD-specific parameters                                    |
| fax               | string        | Optional  | Fax number                                                       |
| first_name        | string        | Required  | First name                                                       |
| last_name         | string        | Required  | Last name                                                        |
| organization_name | string        | Optional  | Organization name (for non-PERSON types)                         |
| phone_number      | string        | Required  | E.164 format (e.g., `+44.1234567890`)                            |
| state             | string        | Optional  | State or province                                                |
| zip_code          | string        | Required  | Postal code                                                      |

## Example: Using a Nested var-file

Create a file like `examples/example.tfvars`:
```hcl
contacts = {
  "1" = {
    address_line_1 = "123 Example Street"
    city           = "Exampleville"
    contact_type   = "COMPANY"
    country_code   = "GB"
    email          = "contact@example.com"
    extra_params = {
      UK_COMPANY_NUMBER = "12345678"
      UK_CONTACT_TYPE   = "LTD"
    }
    first_name        = "Jane"
    last_name         = "Doe"
    organization_name = "Example Ltd"
    phone_number      = "+44.1234567890"
    zip_code          = "EX4 MPL"
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
terraform apply --var-file=./examples/example.tfvars
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

**Notes on .tech, .ltd, .net, .org, and similar TLDs:**

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