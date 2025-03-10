locals {
  foundation_models = compact([var.bedrock_agent_config.foundation_model, try(var.agent_collaborator.foundation_model, null)])

  agent_collaborator = var.agent_collaborator == null ? [] : [var.agent_collaborator]

  knowledge_base_config = merge(var.knowledge_base_config,
    {
      agent_id = var.knowledge_base_config.agent_id == null ? aws_bedrockagent_agent.this[0].agent_id : var.knowledge_base_config.agent_id

    },
    {
      agent_role_name = var.knowledge_base_config.agent_role_name == null ? aws_iam_role.this[0].name : var.knowledge_base_config.agent_role_name

    }
  )
}
