# EKS in Action

> Reading material and code examples

A webinar with A Cloud Guru that showcases how to use Terraform to manage two separate clouds, side by side.

_Note:_ You will need to ensure `wget` is installed locally for the EKS module to validate your EKS cluster's endpoint.

## Table of Contents

- [EKS in Action](#eks-in-action)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Reading material](#reading-material)
    - [HashiCorp Configuration Language](#hashicorp-configuration-language)
  - [First Steps](#first-steps)
  - [Next Steps](#next-steps)
    - [Code Quality](#code-quality)
    - [Modules](#modules)
  - [Author Information](#author-information)
  - [License](#license)

## Prerequisites

As part of this workshop, you will be using [HashiCorp Terraform](https://www.terraform.io) and [Amazon Web Services](https://aws.amazon.com).

For instructions on how to install Terraform. please see our [Learn Guide](https://learn.hashicorp.com/terraform/getting-started/install.html).

On that page, you will find instructions for macOS (using `brew`), Windows (using `choco`) as well as a manual installation path.

## Reading material

This section is a collection of links that will help you make the most of today's session.

### HashiCorp Configuration Language

- repository: [hashicorp/hcl](https://github.com/hashicorp/hcl/tree/hcl2)
- intermediate HCL: [Configuration Languages in HCL2](https://www.hashicorp.com/resources/intermediate-hcl-configuration-languages-in-hcl2/)

## First Steps

- CLI commands [terraform.io/docs/commands/index.html](https://www.terraform.io/docs/commands/index.html)
- variables and type constraints: [terraform.io/docs/configuration/variables.html](https://www.terraform.io/docs/configuration/variables.html#type-constraints)
- variable definition files: [terraform.io/docs/configuration/variables.html](https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files)
- information about Terraform State: [terraform.io/docs/state/index.html](https://www.terraform.io/docs/state/index.html)

## Next Steps

- Learn Guide: Build infrastructure [learn.hashicorp.com/terraform/getting-started/build](https://learn.hashicorp.com/terraform/getting-started/build)
- Build your own AMIs with Packer: [packer.io/docs/builders/amazon/](https://www.packer.io/docs/builders/amazon/)

### Code Quality

Before `plan` and `apply`, always clean up your code:

- use [terraform fmt](https://www.terraform.io/docs/commands/fmt.html) to rewrite Terraform configuration files to a canonical format and style.
- use [terraform validate](https://www.terraform.io/docs/commands/validate.html) to validate the configuration syntax and internal consistency
- use [pre-commit](https://pre-commit.com) to run more checks
  - community member [@antonbabenko](https://github.com/antonbabenko/) built and maintains [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)

### Modules

- use modules as building blocks
- module documentation: [terraform.io/docs/configuration/modules.html](https://www.terraform.io/docs/configuration/modules.html)
- module registry: [registry.terraform.io](https://registry.terraform.io)
- Learn Guide: Modules on [learn.hashicorp.com/terraform/modules/modules-overview](https://learn.hashicorp.com/terraform/modules/modules-overview)

## Author Information

This repository is maintained by [Taylor Dolezal](https://github.com/onlydole) .

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
