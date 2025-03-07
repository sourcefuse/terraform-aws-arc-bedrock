locals {
  foundation_models = compact([var.bedrock_agent_config.foundation_model, try(var.agent_collaborator.foundation_model, null)])

  agent_collaborator = var.agent_collaborator == null ? [] : [var.agent_collaborator]
}
