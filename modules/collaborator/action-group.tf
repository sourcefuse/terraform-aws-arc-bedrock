resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for group in var.action_groups : group.name => group }

  action_group_name          = each.value.name
  action_group_state         = each.value.state
  agent_id                   = var.collaborator_agent_id
  agent_version              = each.value.agent_version
  skip_resource_in_use_check = each.value.skip_resource_in_use_check

  action_group_executor {
    lambda = data.aws_lambda_function.this[each.key].arn
  }

  function_schema {
    dynamic "member_functions" {
      for_each = each.value.function_schema
      content {
        dynamic "functions" {
          for_each = member_functions.value.functions
          content {
            name        = functions.value.name
            description = functions.value.description
            dynamic "parameters" {
              for_each = functions.value.parameters
              content {
                map_block_key = parameters.value.map_block_key
                type          = parameters.value.type
                description   = parameters.value.description
                required      = parameters.value.required
              }
            }
          }
        }
      }
    }
  }
}

locals {
  lambda_permissions = [
    for ag in var.action_groups :
    {
      group_name  = ag.name
      lambda_name = ag.action_group_executor.lambda.name
    }
    if ag.action_group_executor.lambda != null && ag.action_group_executor.lambda.add_permission
  ]
}

data "aws_lambda_function" "this" {
  for_each = { for lambda in local.lambda_permissions : lambda.group_name => lambda }

  function_name = each.value.lambda_name
}

resource "aws_lambda_permission" "bedrock_agent_permission" {
  for_each = { for lambda in local.lambda_permissions : lambda.group_name => lambda }

  statement_id  = "${each.key}-AllowBedrockAgentInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = "bedrock.amazonaws.com"
  source_arn    = var.collaborator_agent_arn
}
