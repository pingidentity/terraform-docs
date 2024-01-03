# Terraform Writing Best Practices

The following provides a set of best practices to apply when writing Terraform with Ping Identity providers and modules.

These guidelines do not intend to educate on the use of Terraform, nor are they a getting started guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with Ping Identity Terraform providers, visit the online [Getting Started](./../index.md) guides.

## General Use

### `plan` First

### Use `--auto-approve` with Caution

### Store State Securely

### Don't Modify State Directly

## HCL Recommendations

### Use Terraform Formatting Tools

### Use `for_each` to iterate maps and objects

### Use `count` for for non-iteratable lists

### Write and Publish Re-usable Modules

## Versioning

### Use Terraform Version Control

Terraform releases change over time, which can include new features and bug fixes.  Major version changes can introduce breaking changes to written code.

To ensure that Terraform HCL is run with consistent results between runs, it's recommended to restrict the version of Terraform in the `terraform {}` block with a lower version limit (in case the HCL includes syntax introduced in a specific version) and an upper version limit to protect against breaking changes.

For example:
```terraform
terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  # ... other configuration parameters
}
```

[Terraform Documentation Reference](https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions)

### Use Provider Version Control

Ping Identity (and other vendors) release changes to providers on a regular basis that can include new features and bug fixes.  Major version changes can introduce breaking changes to written code as older deprecated resources, data sources, parameters and attributes are removed.  Ping Identity follows guidance issued by Hashicorp on [Deprecations, Removals and Renames](https://developer.hashicorp.com/terraform/plugin/framework/deprecations).

To ensure that Terraform HCL is run with a consistent results between runs, it's recommended to restrict the version of each provider in the `terraform.required_providers` parameter with a lower version limit (in case the HCL includes syntax introduced in a specific version) and an upper version limit to protect against breaking changes.

For example:
```terraform
terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 0.21.0, < 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}
```

[Terraform Documentation Reference](https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions)

### Use Module Version Control

Ping Identity (and other vendors) release changes to modules on a regular basis that can include new features and bug fixes.  Major version changes can introduce breaking changes to written code as older deprecated resources, data sources, parameters and attributes are removed.

To ensure that Terraform HCL is run with a consistent results between runs, it's recommended to restrict the version of each module with a lower version limit (in case the HCL includes syntax introduced in a specific version) and an upper version limit to protect against breaking changes.

For example:
```terraform
module "utils" {
  source  = "pingidentity/utils/pingone"
  version = ">= 0.1.0, < 1.0.0"

  # ... other configuration parameters
}
```

[Terraform Documentation Reference](https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions)

## Protect Service Configuration and Data

### Protect Configuration and Data with the `lifecycle.prevent_destroy` Meta Argument

While some resources are safe to remove and replace, there are some resources that, if removed, can result in data loss.

It's recommended to use the `lifecycle.prevent_destroy` meta argument to protect against accidental destroy plans that might cause data to be lost.  You may also want to use the meta argument to prevent accidental removal of access policies and applications if dependent applications cannot be updated with Terraform in case of replacement.

For example:
```terraform
resource "pingone_schema_attribute" "my_attribute" {
  environment_id = pingone_environment.my_environment.id

  name = "myAttribute"
  
  # ... other configuration parameters

  lifecycle {
    prevent_destroy = true
  }
}
```

### Don't Commit Secrets to Source Control

## Multi-team Development

### Use Separate Config-as-Code Repositories for Different Teams

### Use "On-Demand" Development Environments

## Continuous Integration / Continuous Delivery (CI/CD)

### Use Terraform Linting Tools

### Use Terraform Security Scanning Tools

### Check the `.terraform.lock.hcl` File into Source Control



