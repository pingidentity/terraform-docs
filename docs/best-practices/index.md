# Terraform Writing Best Practices

The following provides a set of best practices to apply when writing Terraform with Ping Identity providers and modules in general.  This guide is intended to be used alongside provider and service specific best practices.

These guidelines do not intend to educate on the use of Terraform, nor are they a "Getting Started" guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with Ping Identity Terraform providers, visit the online [Getting Started](./../../getting-started/) guides.

## General Use

### `plan` First Before `apply`

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

When operating production infrastructure with Terraform, the secure storage of Terraform state files is of paramount importance. These files serve as the foundational blueprint of your infrastructure, detailing configurations, credentials, and the current state of resources. Given their critical role, these files inherently contain sensitive information that, if exposed, could be used to gain unauthorized access to user data and manipulation of deployed infrastructure.

To safeguard against these threats, it is vital that robust security measures are implemented around state file storage. This includes:
- Encrypting the state files to protect their contents during transit and at rest
- Employing stringent access controls to ensure only authorized personnel can retrieve or alter the state.  If cloud blob storage is used (such as AWS S3), ensure public access is disabled.
- Leveraging secure storage solutions that offer features like versioning and backups

Hashicorp themselves offer Terraform Cloud that provides secure storage of state out of the box.

Such practices are crucial in maintaining the confidentiality, integrity, and availability of your infrastructure.

For more information about state management when using Terraform, refer to [Hashicorp's online documentation](https://developer.hashicorp.com/terraform/language/state).

### Don't Modify State Directly

Directly modifying Terraform state files is strongly discouraged due to the critical role they play in Terraform's management of infrastructure resources.

The state file acts as a single source of truth for both the configuration and the real-world resources it manages, which is critical when Terraform calculates the differences between "intended" and "actual" configuration when running `terraform plan`.

Manual edits can lead to inconsistencies between the actual state of your infrastructure and Terraform's record, potentially causing unresolvable conflicts in the plan phase, or may result in errors when the provider is reading/writing the state of a resource. Such actions undermine the integrity of your infrastructure management, leading to difficult-to-diagnose issues, resource drift, and potentially the loss or corruption of critical infrastructure.

Instead of directly editing state files, it is best practice to use Terraform's built-in commands such as `terraform state rm` or `terraform import` to safely make changes. This approach ensures that Terraform can accurately track and manage the state of provisioned infrastructure, maintaining the reliability and predictability of your infrastructure as code environment.

For more information about state management when using Terraform, refer to [Hashicorp's online documentation](https://developer.hashicorp.com/terraform/language/state).

### Ensure Provider Warnings are Captured and Reviewed

Terraform providers can produce warnings as a result of operations such as `terraform validate`, `terraform plan` and `terraform apply`.  When these operations are run using the CLI, the warnings are directed to the command line output and when these operations are run in cloud services such as Terraform Cloud, these warnings are shown in the UI.

Ping Identity's Terraform providers can show warnings that need to be captured and reviewed.  For example, the PingOne Terraform provider will produce warnings when specific configuration is used that remove guardrails to prevent accidental deletion of data.

It is highly recommended that warnings shown on the `terraform plan` stage especially are captured reviewed before the `terraform apply` stage is run, as the messages could be alerting the administrator to potential undesired results of the `terraform apply` stage.

## HCL Writing Recommendations

### Use Terraform Formatting Tools

When writing Terraform HCL, using `terraform fmt` is a straightforward yet powerful practice.  `terraform fmt` and equivalent formatting tools adjusts the Terraform code to a standard style, which helps keep the codebase tidy and consistent.  Typically, this means maintaining consistent indentation, spacing and alignment of code. If developing in Visual Studio Code, installing the "Hashicorp Terraform" extension will run `terraform fmt` automatically as you write and save configuration.

This consistency makes your code easier to read and understand for anyone who might work on the project. It's akin to keeping a clean, organised workspace in a physical job — everything is where you expect it to be, reducing confusion and making it easier to spot mistakes.

It's recommended to include `terraform fmt` into the development workflows as it has a big impact on the maintainability and clarity of your infrastructure code. It’s a small effort for a significant gain in code quality and team collaboration.

Additionally, it's recommended to include `terraform fmt` as a CI/CD validation check, to ensure developers are applying consistent development practices when committing configuration-as-code to a common CI/CD pipeline code repository.

### Validate Terraform HCL before Plan and Apply

When writing Terraform HCL, it's recommended to use `terraform validate` before running `terraform plan` and `terraform apply`.

This command serves as a preliminary check, verifying that Terraform HCL configurations are syntactically valid and internally consistent without actually applying any changes.  There are some resources in Ping's Terraform providers that have specific validation logic to ensure that configuration is valid before any platform API is called, which reduces the "time-to-error", if an error exists.

As a specific example, `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> resources validate the `flow_json`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#flow_json" target="_blank">:octicons-link-external-16:</a> input and the specified `connection_link`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#connection_link" target="_blank">:octicons-link-external-16:</a> blocks to make sure re-mapped connections are valid.

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

When writing Terraform HCL, there are considerations around the use of `for_each` when iterating over objects/maps to manage resources.  Using a variable key may result in accidental or unnecessary destruction/re-creation of resources as the data to iterate over changes.  Ping recommends using static keys and maps of objects when using `for_each` rather than lists of objects to control resource creation.

When Terraform creates and stores resources in state, iterated resources must be stored with a defined "key" value, that uniquely identifies the resource against others.  

Therefore it is a best practice to use a map of objects, where there is a static key:
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

Additionally, if the order of the key/object pairs changes in the map, Terraform correctly calculates that there are no changes to the data with the objects themselves, because the relation of object to map key hasn't changed.  This has similar advantages to using `for_each` over `count`, where changing the order of items does impact the plan that Terraform calculates, because the counted index related to the data has changed.

Consider the following example of creating multiple populations using `for_each` over a list of objects, where the objects are maintained as a list in the `for_each` expression using the `name` parameter as the key:
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

However, in this case, if the name of `My awesome population` is changed to `My awesome first population` in the variable, Terraform will destroy that population and re-create it with it's new index value.  This is an unnecessary and dangerous way to change the population name as destruction of populations will put user data at risk.

### Write and Publish Re-usable Modules

When writing Terraform HCL, there are often times when collections of resources and data sources are commonly used together, or used frequently with the same, or very similar structure.  These collections of resources and data sources can be grouped together into a Terraform module.  Writing and publishing Terraform modules embodies a best practice within infrastructure as code (IaC) paradigms for several compelling reasons.

Firstly, modules encapsulate and abstract complex sets of resources and configurations, promoting reusability and reducing redundancy across your infrastructure setups. This modular approach enables teams to define standardized and vetted building blocks, ensuring consistency, compliance, and reliability across deployments. Moreover, publishing these modules, either internally within an organization or publicly in the Terraform Registry, fosters collaboration and knowledge sharing. It allows others to benefit from proven infrastructure patterns, contribute improvements, and stay aligned with the latest best practices. This culture of sharing and collaboration not only accelerates development cycles but also elevates the quality of infrastructure provisioning by leveraging the collective expertise and experience of the Terraform community.

Therefore, writing and publishing Terraform modules is not just about code efficiency; it's about building a foundation for a more innovative, resilient, and collaborative infrastructure management practice.

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

Ping Identity (and other vendors) release changes to providers on a regular basis that can include new features and bug fixes.  Major version changes can introduce breaking changes to written code as older deprecated resources, data sources, parameters and attributes are removed.  Provider versions that are `< 1.0.0` may also include breaking changes to written code.  Ping Identity follows guidance issued by Hashicorp on [Deprecations, Removals and Renames](https://developer.hashicorp.com/terraform/plugin/framework/deprecations).

To ensure that Terraform HCL is run with a consistent results between runs, it's recommended to restrict the version of each provider in the `terraform.required_providers` parameter with a lower version limit (in case the HCL includes syntax introduced in a specific version) and an upper version limit to protect against breaking changes.

For example, the following syntax for the `hashicorp/kubernetes` and `pingidentity/pingdirectory` providers is recommended for provider versions `>= 1.0.0`:
```terraform
terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.2, < 3.0.0"
    }
    pingdirectory = {
      source  = "pingidentity/pingdirectory"
      version = ">= 1.0.2, < 2.0.0"
    }
  }
}
```

The following example syntax for the `pingidentity/pingone` and `hashicorp/time` providers shows the recommended version pinning for provider versions `< 1.0.0` that may incur breaking changes during initial development, though it may also be used for provider versions `>= 1.0.0`:
```terraform
terraform {
  required_version = "~> 1.6"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.27"
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

For example, the following syntax for the `terraform-aws-modules/vpc/aws` module is recommended for module versions `>= 1.0.0`:
```terraform
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.5.1, < 6.0.0"

  # ... other configuration parameters
}
```

The following example syntax for the `pingidentity/utils/pingone` module shows the recommended version pinning for module versions `< 1.0.0` that may incur breaking changes during initial development, though it may also be used for module versions `>= 1.0.0`:
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

### Don't Commit Secrets to Source Control - Use Terraform Variables and Secrets Management

When writing Terraform HCL, it may be tempting to write values that are sensitive (such as OpenID Connect Client Secrets, TLS private key data, service passwords) directly into the code.  There is a significant risk that these secrets are then committed to source control, where they are able to be viewed by anyone who can access that code.  Even more so when the source control is a public Git repository hosted on sites such as Github or Gitlab.

Committing secrets, such as passwords, API keys, and tokens, directly into Terraform configurations and subsequently into source control, poses significant security risks that can have far-reaching consequences. This practice exposes sensitive information to anyone who has access to the repository, including potential unauthorized users, thereby compromising the security of your infrastructure. Once secrets are committed to a repository, removing them requires extensive effort and does not guarantee that they haven't been copied or logged elsewhere.

Moreover, version control systems are designed to track and preserve history, making it challenging to completely erase secrets once they are committed. This persistence in history means that even if the secrets are later removed from the codebase, they remain accessible in the commit history. Additionally, repositories, especially public or shared ones, are often cloned, forked, or integrated with third-party services, further increasing the exposure of secrets.

Ultimately the safest way to recover from secrets that have been leaked is to rotate them in the source system, which can be an impactful activity if other systems or individuals depend on that credential.

To mitigate these risks, it's recommended to use secure secrets management tools and practices. Terraform supports various mechanisms for securely managing secrets, including environment variables, encrypted state files, and integration with dedicated secrets management systems like AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault. These tools provide controlled access to secrets, audit trails, and the ability to rotate secrets periodically or in response to a breach.

By keeping secrets out of source control and employing robust secrets management strategies, users can significantly enhance the security posture of their infrastructure deployments. This approach not only protects sensitive information but also aligns with compliance requirements and best practices for secure infrastructure management.

## Multi-team Development

### Use "On-Demand" Development Environments

The recommended approach for multi-team development, when using a GitOps CICD promotion process, is to spin up "on-demand" development and test environments (where possible), specific to new features or to individual teams, to allow for development and integration testing that doesn't conflict with other team's development and test activities.  The Terraform provider allows administrators to use CICD automation to provision new environments as required, and remove them once the project activity no longer needs them.

In a GitOps CICD promotion pipeline, configuration can be translated to Terraform config-as-code and then merged (with Pull Requests) with common test environments, where automated tests can be run.  This then allows the activities in the "on-demand" environments to be merged into a common promotion pipeline to production environments.

In some cases there may be a lack of available integrated systems that cannot be spun up easily or cannot be integrated with.  For example, this may apply to integrated HR systems, or systems that have been installed onto "bare metal" infrastructure.  In these cases, where possible, connected and unrelated systems can be "stubbed" in the spin-up process, and tested during the "Integration test" phase of the project when changes have been merged into a common promotion pipeline.

In some cases it may not be practical to spin up on-demand development or test environments due to impact on project costs, commercial limitations or limitations in the CI/CD processes.  In this case, it is recommended to create static development environments that are ultimately shared between teams/projects and process introduced to mitigate conflicts.  Ideally these development environments (that doesn't impact project work) have their configuration periodically refreshed and aligned with that of common test environments further down the CI/CD promotion pipeline.  Ensure this activity is appropriately scheduled with the project teams involved to avoid wiping configuration that is still in active development.

## Continuous Integration / Continuous Delivery (CI/CD)

### Use Terraform Linting Tools

Ping recommend using linting tools in the development process, as these tools significantly enhance code quality, maintainability, and consistency across projects.

Linters are static code analysis tools designed to inspect code for potential errors, stylistic discrepancies, and deviations from established coding standards and best practices. By integrating linting tools into the development workflow, developers are proactively alerted to issues such as syntax errors, potential bugs, and security vulnerabilities before the code is even executed or deployed. This immediate feedback loop not only saves time and resources by catching issues early but also facilitates a learning environment where developers can gradually adopt best coding practices and improve their skills.

Furthermore, linting tools play a pivotal role in maintaining codebase consistency, especially in collaborative environments where multiple developers contribute to the same project. They enforce a uniform coding style and standards, reducing the cognitive load on developers who need to understand and work with each other’s code. This standardization is vital for code readability, reducing the complexity of code reviews, and easing the onboarding of new team members.

Moreover, integrating linting tools into continuous integration/continuous deployment (CI/CD) pipelines automates the process of code quality checks, ensuring that only code that meets the defined quality criteria is advanced through the stages of development, testing, and deployment. This automation not only streamlines the development process but also aligns with agile practices and DevOps methodologies, promoting faster, more reliable, and higher-quality software releases.

One of the most common and full featured linting tools is [TFLint](https://github.com/terraform-linters/tflint).

### Use Terraform Security Scanning Tools

Ping recommend that users incorporate Terraform security scanning tools into the development and deployment workflow to help with security and compliance of infrastructure as code (IaC) configurations.

Terraform, while powerful, manages highly sensitive and critical components of cloud infrastructure, making any misconfigurations or vulnerabilities potentially disastrous in terms of security breaches, data leaks, and compliance violations. Security scanning tools are designed to automatically inspect Terraform code for such issues before the infrastructure is provisioned or updated, highlighting practices that could lead to security weaknesses, such as overly permissive access controls, unencrypted data storage, or exposure of sensitive information.

By leveraging these tools, developers can preemptively identify and rectify security vulnerabilities within their infrastructure code, significantly reducing the risk of attacks and breaches. This proactive approach to security is aligned with the principles of DevSecOps, which advocates for "shifting left" on security - that is, integrating security practices early in the software development lifecycle. It ensures that security considerations are embedded in the development process, rather than being an afterthought.

Furthermore, Terraform security scanning tools often provide compliance checks against common regulatory standards and best practices, such as the CIS benchmarks, making it easier for organizations to adhere to industry regulations and avoid penalties. These tools also promote a culture of security awareness among developers, educating them on secure coding practices and the importance of infrastructure security.

Overall, the use of Terraform security scanning tools enhances the security posture of cloud environments, protects against the financial and reputational damage associated with security incidents, and ensures continuous compliance with evolving regulatory requirements. This makes them an indispensable asset in the toolkit of any team working with Terraform and cloud infrastructure.

Example tools for security scanning include [Trivy](https://github.com/aquasecurity/trivy), [Terrascan](https://runterrascan.io/docs/) and [checkov](https://www.checkov.io/)

### Check the `.terraform.lock.hcl` File into Source Control

Including the `.terraform.lock.hcl` file in source control is a recommended best practice for Terraform users, providing several benefits to the infrastructure-as-code (IaC) workflow.

This file serves as a version lock file that records the specific versions of the provider plugins and modules (and their hashes) used in a Terraform configuration.  By checking it into source control, teams ensure consistent and reproducible deployments across different environments.  The lock file acts as a snapshot of the dependencies, guaranteeing that everyone working on the project has the same set of provider and module versions.  This practice enhances collaboration, reduces the likelihood of version mismatches, and mitigates the risk of unexpected changes or disruptions during deployments.  Moreover, it facilitates version tracking and simplifies the process of recreating the infrastructure at a later time.  Overall, checking the `.terraform.lock.hcl` file into source control contributes to the reliability and maintainability of Terraform configurations within a collaborative development environment.

When used with a GitOps process that includes dependency scanning tools (such as Github's Dependabot), automations can be configured to generate automatic pull requests of provider/module version updates that might include bug fixes, enhancements and security patches.  The automated pull requests (and associated checks) can help streamline a CICD workflow, leading to higher productivity and reduced human error.
