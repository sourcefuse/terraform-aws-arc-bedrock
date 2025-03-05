resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for group in var.action_groups : group.name => group }

  action_group_name          = each.value.name
  action_group_state         = each.value.state
  agent_id                   = var.collaborator_agent_id
  agent_version              = each.value.agent_version
  skip_resource_in_use_check = each.value.skip_resource_in_use_check

  action_group_executor {
    lambda = each.value.action_group_executor.lambda
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
