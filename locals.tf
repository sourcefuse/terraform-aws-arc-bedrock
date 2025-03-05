locals {
  foundation_models = compact([var.bedrock_agent_config.foundation_model, var.agent_collaborator.foundation_model])

  agent_collaborator = var.agent_collaborator == null ? [] : [var.agent_collaborator]
}
