# Terraform Writing Best Practices - DaVinci

The following sections provide a set of best practices to apply when writing Terraform with the DaVinci Terraform provider and associated modules.

These guidelines do not intend to educate on the use of Terraform, nor are they a "Getting Started" guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with the DaVinci Terraform provider, visit the online [PingOne DaVinci provider Getting Started](./../../getting-started/davinci/) guide.

## Develop in the Admin Console, Promote using Configuration-As-Code

Ping recommends that use case development activities are performed in the DaVinci web admin console wherever possible.  This recommendation is due to the complex nature of Workforce IAM and Customer IAM deployments that includes policy definition, user experience design and associated testing/validation of designed flows.

After having been developed in the web admin console, configuration can be extracted as configuration-as-code to be stored in source control (such as a Git code repository) and linked with CI/CD tooling to automate the delivery of use cases into test and production environments.

For professionals experienced in DevOps development, configuration may be created and altered outside of the web admin console, but care must be taken when modifying complex configuration such as flow design.

## Example / Bootstrapped Configuration Dependencies

### Deploy to "Clean" Environments, without Example / Bootstrapped Configuration

Example / bootstrapped configuration is deployed automatically by the DaVinci service when an environment is created (or a DaVinci service is provisioned to an existing environment).  This behaviour is the default of the web admin console, and the API.

Example / bootstrapped configuration may be useful as a starting point when initially creating use cases with the service (in the development phase), but will create conflicts when migrating the configuration through to test and production environments.

The definition of the example / bootstrapped configuration for new environment may also change over time, as new features are released and flow creation best practices are defined.  Therefore, an environment created today may not be the same as an environment created a year from now.

As a result, it is best practice to create a new environment as a "clean" (without example or bootstrapped configuration) environment for those environments outside of the initial development one.  An example of how to achieve this using the `DAVINCI_MINIMAL` tag is shown below:

#### Terraform Example
```hcl
resource "pingone_environment" "my_environment" {
  name        = "New Environment"
  description = "My new environment"
  type        = "SANDBOX"
  license_id  = var.license_id

  services = [
    {
      type = "SSO"
    },
    {
      type = "DaVinci"
      tags = ["DAVINCI_MINIMAL"]
    }
  ]
}
```

#### cURL Example
```shell
curl --location --request POST '{{apiPath}}/environments' \
--header 'Authorization: Bearer {{accessToken}}' \
--header 'Content-Type: application/json' \
--data-raw '{
  "name": "New-Env_{{$timestamp}}",
  "description": "New environment description",
  "type": "SANDBOX",
  "region": "NA",
  "icon": "https://example.com/icons/environment.jpg",
  "billOfMaterials": {
    "tags": [
      "DAVINCI_MINIMAL"
    ]
    "products": [
      {
        "type": "PING_ONE_BASE",
        "description": "New environment product description",
        "console": {
          "href": "https://example.com"
        }
      }
      {
        "type": "PING_ONE_DAVINCI",
        "description": "New environment product description",
        "console": {
          "href": "https://example.com"
        }
      }
    ]
  },
  "license": {
    "id": "{{licenseID}}"
  }
}'
```

### Define All Configuration Dependencies in Terraform (or elsewhere in the Pipeline)

Example / bootstrapped configuration is deployed automatically by the DaVinci service when an environment is created (or a DaVinci service is provisioned to an existing environment).  This behaviour is the default of the web admin console, and the API.

Example / bootstrapped configuration may be useful as a starting point when initially starting with the service (in the development phase), but will create conflicts when migrating the configuration through to test and production environments.

The configurations of the example / bootstrapped configuration for new environment may also change over time, as new features are released and flow creation best practices are defined.  Therefore, an environment created today may not be the same as an environment created a year from now.

Therefore, it is best practice to explicitly define all configuration dependencies in Terraform (or as a prior step in the CICD pipeline) after developing flows for use cases.  Most notably, this practice includes defining the connectors that a flow uses in HCL, rather than using the example / bootstrapped environment examples.

#### Not best practice

The below `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> definition is not best practice, as it does not define connections that the flow depends on.  In this case, there is an implicit link to example / bootstrapped connector (or subflow) configuration that may not be consistent when promoting up through test and production.

```hcl
resource "davinci_flow" "test-flow-1" {
  environment_id = pingone_environment.my_environment.id

  flow_json = file("./flows/full-minimal.json")
}
```

#### Best practice

The below `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> definition is best practice (where there is only one connector node in this particular flow), as it does define its dependent connections in the `connection_link`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#nestedblock--connection_link" target="_blank">:octicons-link-external-16:</a> block mapping.  The `errorConnector` connector is also explicitly defined with the `davinci_connection`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/connection" target="_blank">:octicons-link-external-16:</a> resource, meaning there will be a consistent configuration when promoting up through test and production.

```hcl
resource "davinci_connection" "test-error" {
  environment_id = pingone_environment.my_environment.id
  connector_id   = "errorConnector"
  name           = "my-new-error"
}

resource "davinci_flow" "test-flow-1" {
  environment_id = pingone_environment.my_environment.id

  flow_json = file("./flows/full-minimal.json")

  connection_link {
    id                           = davinci_connection.test-error.id
    name                         = davinci_connection.test-error.name
    replace_import_connection_id = "53ab************************1ac8"
  }
}
```

### Remove Example / Bootstrapped Configuration from Existing Environments

When following best practices in this section, there may be occasions where example / bootstrapped configuration is present within the environment but is not actively used to fulfil any use cases.  This "orphaned configuration" should be removed and use-cases retested so the configuration does not confuse any audit activities, and to prevent its accidental use at a later date.

## HCL Writing Recommendations

### Validate `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> Terraform HCL before Plan and Apply

When writing Terraform HCL, it is recommended to use `terraform validate` before running `terraform plan` and `terraform apply` when the HCL includes `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> resources.

This command serves as a preliminary check, verifying that Terraform HCL configurations are syntactically valid and internally consistent without actually applying any changes.  There are some resources in Ping's Terraform providers that have specific validation logic to ensure that configuration is valid before any platform API is called, which reduces the "time-to-error", if an error exists.

In this example, `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> resources validate the `flow_json`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#flow_json" target="_blank">:octicons-link-external-16:</a> input and the specified `connection_link`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#connection_link" target="_blank">:octicons-link-external-16:</a> and `subflow_link`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#subflow_link" target="_blank">:octicons-link-external-16:</a> blocks to make sure re-mapped connections and subflows are valid.

## Multi-team Development

### Use "On-Demand" Sandbox Environments

PingOne customer tenants have a "tenant-in-tenant" architecture, whereby a PingOne tenant organisation that is licensed for DaVinci can contain many individual environments.  These individual environments can be purposed for development, test, pre-production and production purposes.  These separate environments allow for easy maintenance of multiple development and test instances.

The recommended approach for multi-team development, when using a GitOps CICD promotion process, is to spin up "on-demand" development and test environments, specific to new features or to individual teams, to allow for development and integration testing that does not conflict with other team's development and test activities.  The Terraform provider allows administrators to use CICD automation to provision new environments as required, and remove them after the project activity no longer needs them.

In a GitOps CICD promotion pipeline, configuration can be translated to Terraform config-as-code and then merged (with Pull Requests) with common test environments, where automated tests can be run.  This flow allows the activities in the "on-demand" environments to be merged into a common promotion pipeline to production environments.

## User Administrator Role Assignment

### Use Group Role Assignments Over Terraform Managed User Role Assignments

As of 24th October 2023, the PingOne platform supports assigning administrator roles groups, such that members of the group get the administrator roles assigned.

When creating environments with the DaVinci service enabled, administrator users will not be able to manage flow configuration until provisioned with the **DaVinci Admin** role.  The **DaVinci Admin** role can be assigned to groups, and users assigned to that group, in order to be given permissions to configure flows.  The **DaVinci Admin** role can be scoped to the environment, or to the whole organisation.  If a group is assigned the **DaVinci Admin** role scoped to the organisation (for example), any user in that group will automatically get admin access to new DaVinci environments.

Ping recommends that groups with admin role assignments are controlled by the Joiner/Mover/Leaver Identity Governance processes, separate to the Terraform CICD process that configures applications, policies, domain verification and so on.  It may be that the groups with their role assignments are initially seeded by a Terraform.  In this case, it should still be a separate Terraform process to the process that controls platform configuration, and the user group assignments should still happen in the Joiner/Mover/Leaver Identity Governance process.

Terraform can be used to assign administrator roles to individuals directly, however this is not recommended best practice except in development (or generally non-production) environments.  Ping recommends that role assignment processes in non-production environments align as close as possible to role assignment processes in production environments.
