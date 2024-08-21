This example is a simplified reference demonstrating how a CICD pipeline might work for Ping Identity solutions. Configuration managed in this example is made of shared "platform-level" components that would be managed by a centralized IAM team in order to be used by internal or partner applications.

[Ping Platform Example Pipeline](https://github.com/pingidentity/pipeline-example-platform) - The documentation is presented as a guided tutorial within the GitHub Repository

In this repository, the processes and features shown in a GitOps process of developing and delivering a new feature include:

- Feature Request Template
- On-demand development environment deployment
- Building a feature in development environment (PingOne UI)
- Extracting feature configuration to be stored as code
- Validating the extracted configuration from the developer perspective
- Validating that the suggested configuration adheres to contribution guidelines
- Review process of suggested change
- Approval of change and automatic deployment into higher environments
