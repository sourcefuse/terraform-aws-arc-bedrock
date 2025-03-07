# terraform-aws-module-template example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | 2.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.89.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bedrock_agent"></a> [bedrock\_agent](#module\_bedrock\_agent) | ../../ | n/a |
| <a name="module_opensearch_serverless"></a> [opensearch\_serverless](#module\_opensearch\_serverless) | sourcefuse/arc-opensearch/aws | 1.0.5 |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | Agent arn |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | Agent ID |
| <a name="output_agent_role_arn"></a> [agent\_role\_arn](#output\_agent\_role\_arn) | Agent Role arn |
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | ARN of the alias |
| <a name="output_alias_id"></a> [alias\_id](#output\_alias\_id) | Unique identifier of the alias. |
| <a name="output_collaborator_agent_id"></a> [collaborator\_agent\_id](#output\_collaborator\_agent\_id) | Agent ID created for collaborators. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
