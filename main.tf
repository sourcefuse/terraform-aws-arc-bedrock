resource "aws_iam_role" "this" {
  count              = var.bedrock_agent_config.create ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.agent_trust.json
  name               = "${var.bedrock_agent_config.name}-role"
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  count  = var.bedrock_agent_config.create ? 1 : 0
  policy = data.aws_iam_policy_document.agent_permissions.json
  role   = aws_iam_role.this[0].id
}

resource "aws_iam_role" "collaborator" {
  for_each = { for idx, collaborator in local.agent_collaborator : collaborator.name => collaborator }

  assume_role_policy = data.aws_iam_policy_document.agent_trust.json
  name               = "${each.key}-collaborator-role"
  tags               = var.tags
}

resource "aws_iam_role_policy" "collaborator" {
  for_each = { for idx, collaborator in local.agent_collaborator : collaborator.name => collaborator }

  policy = data.aws_iam_policy_document.collaborator_agent_permissions.json
  role   = aws_iam_role.collaborator[each.key].id
}

resource "aws_bedrockagent_agent" "this" {
  count = var.bedrock_agent_config.create ? 1 : 0

  agent_name                  = var.bedrock_agent_config.name
  description                 = var.bedrock_agent_config.description
  agent_resource_role_arn     = aws_iam_role.this[0].arn
  idle_session_ttl_in_seconds = var.bedrock_agent_config.idle_session_ttl_in_seconds
  foundation_model            = var.bedrock_agent_config.foundation_model
  instruction                 = var.bedrock_agent_config.instruction
  agent_collaboration         = var.bedrock_agent_config.agent_collaboration
  prepare_agent               = var.bedrock_agent_config.prepare_agent
  tags                        = var.tags

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [aws_bedrockagent_agent.collaborator]
}

resource "aws_bedrockagent_agent_alias" "this" {
  count = var.bedrock_agent_config.create && var.bedrock_agent_config.alias_name != null ? 1 : 0

  agent_alias_name = var.bedrock_agent_config.alias_name
  agent_id         = aws_bedrockagent_agent.this[0].agent_id
  description      = var.bedrock_agent_config.alias_description
  tags             = var.tags
}

resource "aws_bedrockagent_agent" "collaborator" {
  for_each = { for idx, collaborator in local.agent_collaborator : collaborator.name => collaborator }

  agent_name                  = each.value.name
  description                 = each.value.description
  agent_resource_role_arn     = aws_iam_role.collaborator[each.key].arn
  idle_session_ttl_in_seconds = each.value.idle_session_ttl_in_seconds
  instruction                 = each.value.instruction
  prepare_agent               = each.value.prepare_agent
  foundation_model            = each.value.foundation_model
  tags                        = var.tags
}


// Note:-  If we use var.agent_collaborators then we are facing Error: Prepare operation can't be performed on Agent when it is
// │ in Preparing state. Retry the request when the agent is in a valid state.
module "collaborators" {
  source   = "./modules/collaborator"
  for_each = { for idx, collaborator in local.agent_collaborator : collaborator.name => collaborator }

  collaborator_agent_id      = aws_bedrockagent_agent.collaborator[each.key].agent_id
  collaborator_agent_arn     = aws_bedrockagent_agent.collaborator[each.key].agent_arn
  collaborator_name          = each.value.collaborator_name
  supervisor_agent_id        = each.value.supervisor_agent_id == null ? aws_bedrockagent_agent.this[0].agent_id : each.value.supervisor_agent_id
  collaboration_instruction  = each.value.collaboration_instruction
  alias_name                 = each.value.alias_name
  description                = each.value.description
  relay_conversation_history = each.value.relay_conversation_history

  action_groups = each.value.action_groups

  tags = var.tags

  depends_on = [aws_bedrockagent_agent.this, aws_bedrockagent_agent.collaborator]
}

module "knowledge_base" {
  source = "./modules/knowledge-base"
  count  = var.knowledge_base_config.create ? 1 : 0

  namespace             = var.namespace
  environment           = var.environment
  knowledge_base_config = local.knowledge_base_config
  tags                  = var.tags
}
