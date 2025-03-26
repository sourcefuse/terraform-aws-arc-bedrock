resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = var.alias_name
  agent_id         = var.collaborator_agent_id
  description      = var.description
  tags             = var.tags

  depends_on = [aws_bedrockagent_agent_action_group.this]
}

resource "aws_bedrockagent_agent_collaborator" "this" {
  agent_id                   = var.supervisor_agent_id
  collaboration_instruction  = var.collaboration_instruction
  collaborator_name          = var.collaborator_name
  relay_conversation_history = var.relay_conversation_history

  agent_descriptor {
    alias_arn = aws_bedrockagent_agent_alias.this.agent_alias_arn
  }

  depends_on = [aws_bedrockagent_agent_alias.this]
}
