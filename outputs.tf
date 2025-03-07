output "agent_arn" {
  value       = var.bedrock_agent_config.create ? aws_bedrockagent_agent.this[0].agent_arn : null
  description = "Agent arn"
}

output "agent_id" {
  value       = var.bedrock_agent_config.create ? aws_bedrockagent_agent.this[0].agent_id : null
  description = "Agent ID"
}

output "collaborator_agent_id" {
  description = "Agent ID created for collaborators."
  value       = { for k, v in aws_bedrockagent_agent.collaborator : k => v.agent_id }
}

output "agent_role_arn" {
  value       = var.bedrock_agent_config.create ? aws_iam_role.this[0].arn : null
  description = "Agent Role arn"
}

output "collaborator_role_arns" {
  description = "ARNs of the IAM roles created for collaborators."
  value       = { for k, v in aws_iam_role.collaborator : k => v.arn }
}

output "alias_arn" {
  value       = var.bedrock_agent_config.create && var.bedrock_agent_config.alias_name != null ? aws_bedrockagent_agent_alias.this[0].agent_alias_arn : 0
  description = "ARN of the alias"
}

output "alias_id" {
  description = "Unique identifier of the alias."
  value       = var.bedrock_agent_config.create && var.bedrock_agent_config.alias_name != null ? aws_bedrockagent_agent_alias.this[0].agent_alias_id : 0
}
