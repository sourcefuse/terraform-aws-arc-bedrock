# terraform-aws-module-template example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bedrock_agent"></a> [bedrock\_agent](#module\_bedrock\_agent) | ../../ | n/a |
| <a name="module_collaborator_agent_1"></a> [collaborator\_agent\_1](#module\_collaborator\_agent\_1) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_arn"></a> [agent\_arn](#output\_agent\_arn) | Agent arn |
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | Agent ID |
| <a name="output_agent_role_arn"></a> [agent\_role\_arn](#output\_agent\_role\_arn) | Agent Role arn |
| <a name="output_collaborator_agent_id"></a> [collaborator\_agent\_id](#output\_collaborator\_agent\_id) | Agent ID created for collaborators. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
