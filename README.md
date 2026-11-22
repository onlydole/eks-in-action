# EKS in Action

> Reading material and code examples

Creating an EKS cluster and VPC in AWS.

_Note:_ This example needs Terraform 1.5.7 or later.

_Note:_ The EKS API endpoint is public and open to any address by default. To narrow it to your own IP, set this in a `terraform.tfvars` file or as a Terraform Cloud variable.

```hcl
cluster_endpoint_public_access_cidrs = ["203.0.113.10/32"]
```

_Note:_ The identity that runs `terraform plan` needs `eks:DescribeAddonVersions`, because the EKS module looks up add-on versions during the plan.

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

A fresh install needs none of these steps. Older versions of this example used EKS module v18 and the `aws-auth` ConfigMap.
To move a cluster built with them, go in stages and read every plan before you apply it.
The [EKS module v20 upgrade guide](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v21.29.0/docs/UPGRADE-20.0.md) and the AWS guide to [migrating aws-auth entries to access entries](https://docs.aws.amazon.com/eks/latest/userguide/migrating-access-entries.html) have the details.

1. Switch the cluster to access entries before you change any Terraform code. Keep `aws-auth` in place for now.
   Wait for the cluster to return to `ACTIVE` before the next step.

   ```shell
   aws eks update-cluster-config --name eks-in-action --access-config authenticationMode=API_AND_CONFIG_MAP
   aws eks wait cluster-active --name eks-in-action
   ```

1. Check that the managed node group role has its access entry. EKS adds it for you, and nodes stop joining if it's missing once `aws-auth` is gone.
   Look up the node role, then describe its entry. Its type should be `EC2_LINUX`.

   ```shell
   aws eks list-nodegroups --cluster-name eks-in-action
   aws eks describe-nodegroup --cluster-name eks-in-action --nodegroup-name <worker-node-group> --query nodegroup.nodeRole
   aws eks describe-access-entry --cluster-name eks-in-action --principal-arn <node-role-arn>
   ```

1. Check that the principal Terraform runs as has cluster admin through an access entry.
   `kubectl get nodes` isn't proof, because it can still succeed through `aws-auth` in this mode.
   Run `aws sts get-caller-identity` as that principal. For an assumed role, use the role ARN in the form `arn:aws:iam::111122223333:role/terraform`, not the session ARN.

   ```shell
   aws eks describe-access-entry --cluster-name eks-in-action --principal-arn arn:aws:iam::111122223333:role/terraform
   aws eks list-associated-access-policies --cluster-name eks-in-action --principal-arn arn:aws:iam::111122223333:role/terraform
   ```

   If the principal created the cluster, EKS already made its entry. Otherwise create one with `aws eks create-access-entry`.
   If `AmazonEKSClusterAdminPolicy` isn't listed with a `cluster` scope, add it with `aws eks associate-access-policy`.
   Don't go on until the policy shows up for that principal.

1. Hand the entry to Terraform. It already exists, so `enable_cluster_creator_admin_permissions = true` would try to create a second one and fail with `ResourceInUseException`.
   Either set it to `false` and leave the entry outside Terraform, or adopt it with temporary import blocks.

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

1. Decide whether the VPC module should adopt the VPC's default resources now. VPC module v4 and later manage the default security group, network ACL, and route table, and v3 didn't.
   On first adoption, Terraform removes every rule from the default security group, removes every rule from the default network ACL and then adds back the module's allow-all rules, and removes every route from the default route table.
   To defer that for an existing VPC, add these to the `vpc` module and plan the adoption later on its own.

   ```hcl
   manage_default_security_group = false
   manage_default_network_acl    = false
   manage_default_route_table    = false
   ```

1. Plan the module upgrade and check these parts of it.
   - The `aws-auth` ConfigMap is destroyed. That is expected, because every entry in it was a managed node group role. Apply only after steps 2 and 3 succeed.
   - The `worker` node group is replaced, because v21 node groups default to AL2023 instead of AL2. Pods move to the new nodes.
   - The cluster already runs self-managed VPC CNI, kube-proxy, and CoreDNS. Add `resolve_conflicts_on_create = "OVERWRITE"` to each entry in `addons` for this apply so EKS adopts them.
   - The VPC default resources change as described in step 6, unless you deferred them.

1. Upgrade Kubernetes one minor version per apply. Raise `cluster_version` by one, apply, and repeat until you reach the default of 1.36.

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
