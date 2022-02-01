# Custom AWS Load Balancer Controller Deployment

Deploying AWS Load Balancer Controller using the customised settings:

[![Terraform](https://img.shields.io/badge/tf->%3D0.14.8-blue.svg)](https://www.terraform.io/downloads)


## Usage

To run this example you need to execute:

```bash

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_SESSION_TOKEN=""

export TF_VAR_k8s_cluster_name="Test"

$ terraform init
$ terraform plan
$ terraform apply
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.63 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.63 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_lb_controller"></a> [aws\_lb\_controller](#module\_aws\_lb\_controller) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
