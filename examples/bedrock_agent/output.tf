output "agent_arn" {
  value       = module.bedrock_agent.agent_arn
  description = "Agent arn"
}

output "agent_id" {
  value       = module.bedrock_agent.agent_id
  description = "Agent ID"
}

output "collaborator_agent_id" {
  description = "Agent ID created for collaborators."
  value       = module.bedrock_agent.collaborator_agent_id
}

output "agent_role_arn" {
  value       = module.bedrock_agent.agent_role_arn
  description = "Agent Role arn"
}
