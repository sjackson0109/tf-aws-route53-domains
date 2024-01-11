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
In this project, with the `aws_route53domains_registered_domain` resource class is used. Please note that IMPORTED AUTOMATICALLY (with terraform apply).
If you perform a `terraform destroy` command, the state-file is the ONLY place the domains are remove. They are not purged from your AWS Route53 account!

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

# Recommendations
I recommend doing this for ONE domain first, for every set of unique contact details you need to set; then doing the rest after you confirmed that is successful. Why?
Because of the following Error:
```
│ Error: waiting for Route 53 Domains Domain ("mytestdomain.com") contacts update: timeout while waiting for state to become 'SUCCESSFUL' (last state: 'IN_PROGRESS', timeout: 30m0s)
```
How to fix this: simply go to the mailbox of the contact, and click on the verify contact details link.


# Terraform state (example):
aws_route53domains_registered_domain.this["mytestdomain.com"]