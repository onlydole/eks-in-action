# EKS in Action

> Reading material and code examples

Creating an EKS cluster and VPC in AWS.

_Note:_ This example needs Terraform 1.5.7 or later.

_Note:_ The EKS API endpoint is public and open to any address by default. To narrow it to your own IP, set this in a `terraform.tfvars` file or as a Terraform Cloud variable.

```hcl
cluster_endpoint_public_access_cidrs = ["203.0.113.10/32"]
```

## Table of Contents

- [EKS in Action](#eks-in-action)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Upgrading an existing cluster](#upgrading-an-existing-cluster)
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

## Upgrading an existing cluster

A fresh install needs none of these steps. Older versions of this example used EKS module v18 and the `aws-auth` ConfigMap. To move a cluster built with them, go in stages and read every plan before you apply it. The [EKS module v20 upgrade guide](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v21.29.0/docs/UPGRADE-20.0.md) has the details.

1. Switch the cluster to access entries before you change any Terraform code. Keep `aws-auth` in place for now.

   ```shell
   aws eks update-cluster-config --name eks-in-action --access-config authenticationMode=API_AND_CONFIG_MAP
   ```

   EKS then creates access entries for the original cluster creator and for the managed node group roles.

1. Check that access still works before anything else changes.

   ```shell
   aws eks list-access-entries --cluster-name eks-in-action
   kubectl get nodes
   ```

1. Handle the cluster creator entry. If Terraform runs as the identity that created the cluster, `enable_cluster_creator_admin_permissions = true` tries to create a second entry for it and fails with `ResourceInUseException`.
   Either set it to `false` and keep the entry EKS made, or adopt that entry with temporary import blocks. Use the principal ARN that `list-access-entries` shows, and import the policy association only if `aws eks list-associated-access-policies` lists one.

   ```hcl
   import {
     to = module.eks.aws_eks_access_entry.this["cluster_creator"]
     id = "eks-in-action:arn:aws:iam::111122223333:role/terraform"
   }

   import {
     to = module.eks.aws_eks_access_policy_association.this["cluster_creator_admin"]
     id = "eks-in-action#arn:aws:iam::111122223333:role/terraform#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
   }
   ```

1. Set `cluster_version` to the version the cluster runs now, from `aws eks describe-cluster --name eks-in-action --query cluster.version`, so the module upgrade doesn't also change Kubernetes.

1. Plan the module upgrade and check these parts of it.
   - The `aws-auth` ConfigMap is destroyed. That is expected, because every entry in it was a managed node group role and EKS now covers those with access entries. Apply only after step 2 succeeds.
   - The `worker` node group is replaced, because v21 node groups default to AL2023 instead of AL2. Pods move to the new nodes.
   - The cluster already runs self-managed VPC CNI, kube-proxy, and CoreDNS. Add `resolve_conflicts_on_create = "OVERWRITE"` to each entry in `addons` for this apply so EKS adopts them.
   - VPC module v4 and later manage the VPC's default security group, network ACL, and route table. The plan adopts them, and the module's defaults remove all rules from the default security group.

1. Upgrade Kubernetes one minor version per apply. Raise `cluster_version` by one, apply, and repeat until you reach the default.

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
