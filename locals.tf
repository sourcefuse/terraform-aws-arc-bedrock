locals {
  foundation_models = compact([var.bedrock_agent_config.foundation_model, var.agent_collaborator.foundation_model])
}
