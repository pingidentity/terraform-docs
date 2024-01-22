# Terraform Writing Best Practices

The following provides a set of best practices to apply when writing Terraform with Ping Identity providers and modules in general.  This guide is intended to be used alongside provider and service specific best practices.

These guidelines do not intend to educate on the use of Terraform, nor are they a getting started guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with Ping Identity Terraform providers, visit the online [Getting Started](./../index.md) guides.

## General Use

### `plan` First

Running `terraform plan` before `terraform apply` is a crucial practice for Terraform users as it provides a proactive approach to infrastructure management. The `plan` command generates an execution plan, detailing the changes that Terraform intends to make to the infrastructure. By reviewing this plan, administrators will gain insight into the potential modifications, additions, or deletions of configured resources.

This preview allows administrators to assess the impact of the proposed changes, identify any unexpected alterations, and verify that the configuration aligns with their intentions. This preventive step helps in avoiding unintended consequences and costly mistakes, ensuring a smoother and more controlled deployment process. Skipping the `plan` phase and directly executing `apply` may lead to inadvertent alterations, risking the stability and integrity of the infrastructure. Therefore, incorporating `terraform plan` as an integral part of the workflow, potentially as an automation in the "Pull Request" stage of a GitOps process, promotes responsible and informed infrastructure management practices.

### Use `--auto-approve` with Caution

Use of the `--auto-approve` feature in Terraform can lead to unintended and potentially destructive changes in your infrastructure. When running Terraform commands, such as `terraform apply`, without the `--auto-approve` flag, Terraform will provide a plan of the changes it intends to make and ask for confirmation before applying those changes.

By using `--auto-approve`, the process of reviewing planned changes to configuration and infrastructure is skipped, and Terraform immediately applies the changes. This can be risky for several reasons:

* **Accidental Changes**: Without reviewing the plan, unintended changes may inadvertently be applied to the environment.  This is especially dangerous in production environments where mistakes can have significant consequences, such as causing breaking changes causing outage or use case failure.
* **Destructive Changes**: Terraform may plan to destroy resources as part of the update.  Without manual confirmation, unintentional removal of critical configuration or infrastructure may occur.  This applies to both `terraform apply` and `terraform destroy` commands.
* **Security Implications**: Auto-approving changes without verification increases the risk of security vulnerabilities. For example, sensitive data may unintentionally be exposed, or access policies may be negated or weakened.

To minimize the risks associated with `--auto-approve`, Ping recommends to review the Terraform plan before applying changes.  This ensures that admins have a clear understanding of what modifications Terraform intends to make to live service configuration and infrastructure.

### Store State Securely

### Don't Modify State Directly

## HCL Recommendations

### Use Terraform Formatting Tools

### Using `count` and `for_each` with resource iteration

When writing Terraform HCL, there are considerations around when to use `count` and when to use `for_each`, especially when iterating over resources.  Using the incorrect iteration method may result in accidental or unnecessary destruction/re-creation of resources as the data to iterate over changes.

Consider the following example, where a number of populations are being created from an array variable:
```terraform
locals {
  populations = [
    "Retail Customers",
    "Business Customers",
    "Business Partners",
  ]
}

resource "pingone_population" "my_populations" {
  count = length(local.populations)
  
  environment_id = pingone_environment.my_environment.id
  name           = local.populations[count.index]
}
```

The HCL will create the populations successfully, but we will run into problems when the order of the array changes (for example, if it's sorted alphabetically in the code):

```terraform
locals {
  populations = [
    "Business Customers",
    "Business Partners",
    "Retail Customers",
  ]
}

resource "pingone_population" "my_populations" {
  count = length(local.populations)
  
  environment_id = pingone_environment.my_environment.id
  name           = local.populations[count.index]
}
```

```
Terraform will perform the following actions:

  # pingone_population.my_populations[0] will be updated in-place
  ~ resource "pingone_population" "my_populations" {
        id             = "91ffa912-e24e-4fa7-a0f3-7fb48539f756"
      ~ name           = "Retail Customers" -> "Business Customers"
        # (1 unchanged attribute hidden)
    }

  # pingone_population.my_populations[1] will be updated in-place
  ~ resource "pingone_population" "my_populations" {
        id             = "f2df301c-c2a1-436b-afaf-33eb189fe7d6"
      ~ name           = "Business Customers" -> "Business Partners"
        # (1 unchanged attribute hidden)
    }

  # pingone_population.my_populations[2] will be updated in-place
  ~ resource "pingone_population" "my_populations" {
        id             = "f2df828e-cfd6-4ecb-815d-5bd33c566fa8"
      ~ name           = "Business Partners" -> "Retail Customers"
        # (1 unchanged attribute hidden)
    }
```

In the above situation, user's are inadvertently being moved from one population to another based on the names of the populations.  Any downstream application that requires a hardcoded UUID for "Retail Customers" (for example) will instead return "Business Partners" identities.

The problem is compounded if adding and removing elements to/from the array.  This is an example of when to use `for_each` instead of `count`, as `for_each` will identify and store each resource with a unique key.  Including guidance from the [Use maps with static keys when using `for_each` on resources](#use-maps-with-static-keys-when-using-for-each-on-resources) best practice, the following HCL is the recommended way to perform the same iteration:

```terraform
locals {
  populations = {
    "business_customers" = "Business Customers",
    "retail_customers"   = "Retail Customers",
    "business_partners"  = "Business Partners",
  }
}

resource "pingone_population" "my_populations" {
  for_each = local.populations
  
  environment_id = pingone_environment.my_environment.id
  name           = each.value
}
```

### Use maps with static keys when using `for_each` on resources

When writing Terraform HCL, there are considerations around the use of `for_each` when iterating over objects/maps to manage resources.  Using a variable key may result in accidental or unnecessary destruction/re-creation of resources as the data to iterate over changes.  Ping recommends using static keys and maps of objects when using `for_each` to control resource creation.

When Terraform creates and stores resources in state, iterated resources must be stored with a defined "key" value, that uniquely identifies the resource against others.  Consider the following example of creating multiple populations using `for_each` over a list of objects, where the objects are converted to a map in the `for_each` expression using the `name` parameter as the key:
```terraform
variable "populations" {
  type = list(object({
    name        = string
    description = optional(string)
  }))

  default = [
    {
      name        = "My awesome population"
      description = "My awesome population for awesome people"
    },
    {
      name = "My awesome second population"
    }
  ]
}

resource "pingone_population" "my_awesome_population_list_of_objects" {
  environment_id = pingone_environment.my_environment.id

  for_each = { for population in var.populations : population.name => population }

  name        = each.key
  description = each.value.description
}
```

The above results in creation of two unique resources:

* `pingone_population.my_awesome_population_list_of_objects["My awesome population"]`
* `pingone_population.my_awesome_population_list_of_objects["My awesome second population"]`

Notice that, if the name of `My awesome population` is changed to `My awesome first population` in the variable, Terraform wants to destroy that population and re-create it with it's new index value.  While this is an unnecessary way to change the population name, destruction of populations may put user data at risk.

It would be better practice therefore to use a map of objects, where there is a static key:
```terraform
variable "populations" {
  type = map(object({
    name        = string
    description = optional(string)
  }))

  default = {
    "first_population" = {
      name        = "My awesome population"
      description = "My awesome population for awesome people"
    },
    "second_population" = {
      name = "My awesome second population"
    }
  }
}

resource "pingone_population" "my_awesome_population_map_of_objects" {
  environment_id = pingone_environment.my_environment.id

  for_each = var.populations

  name        = each.value.name
  description = each.value.description
}
```

The above results in creation of two unique resources:

* `pingone_population.my_awesome_population_list_of_objects["first_population"]`
* `pingone_population.my_awesome_population_list_of_objects["second_population"]`

In this case, if the `name` or `description` of any population changes, Terraform will correctly update the impacted resource, rather than potentially forcing a re-creation.

Notice also, that if the order of the key/object pairs changes in the map, Terraform correctly calculates that there are no changes to the data with the objects themselves, because the relation of object to map key hasn't changed.  This is advantage of using `for_each` over `count`, where changing the order of items does impact the plan that Terraform calculates, because the counted index related to the data has changed.

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

Another example that limits to a specific minor version:
```terraform
terraform {
  required_version = "~> 1.6"

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

Other examples that limit the providers to specified minor versions:
```terraform
terraform {
  required_version = "~> 1.6"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.25"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
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

Another example that limits the module to a specific minor version:
```terraform
module "utils" {
  source  = "pingidentity/utils/pingone"
  version = "~> 0.1"

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

Including the `.terraform.lock.hcl` file in source control is a recommended best practice for Terraform users, providing several benefits to the infrastructure-as-code (IaC) workflow.

This file serves as a version lock file that records the specific versions of the provider plugins and modules (and their hashes) used in a Terraform configuration.  By checking it into source control, teams ensure consistent and reproducible deployments across different environments.  The lock file acts as a snapshot of the dependencies, guaranteeing that everyone working on the project has the same set of provider and module versions.  This practice enhances collaboration, reduces the likelihood of version mismatches, and mitigates the risk of unexpected changes or disruptions during deployments.  Moreover, it facilitates version tracking and simplifies the process of recreating the infrastructure at a later time.  Overall, checking the `.terraform.lock.hcl` file into source control contributes to the reliability and maintainability of Terraform configurations within a collaborative development environment.

When used with a GitOps process that includes dependency scanning tools (such as Github's Dependabot), automations can be configured to generate automatic pull requests of provider/module version updates that might include bug fixes, enhancements and security patches.  The automated pull requests (and associated checks) can help streamline a CICD workflow, leading to higher productivity and reduced human error.
