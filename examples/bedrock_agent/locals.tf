locals {

  collaborators = [
    {
      name                        = "collab-2"
      supervisor_agent_id         = module.bedrock_agent.agent_id
      collaborator_name           = "Collaborator-Two"
      foundation_model            = "anthropic.claude-3-5-sonnet-20241022-v2:0"
      instruction                 = "do what the supervisor is asking you to do"
      collaboration_instruction   = "tell the other agent on what to do"
      alias_name                  = "TechSupport"
      description                 = "Collaborator 2"
      relay_conversation_history  = "TO_COLLABORATOR"
      prepare_agent               = true
      idle_session_ttl_in_seconds = 600
      action_groups               = local.action_groups
    },
    {
      name                        = "collab-3"
      supervisor_agent_id         = module.bedrock_agent.agent_id
      collaborator_name           = "Collaborator-Three"
      foundation_model            = "anthropic.claude-3-5-sonnet-20241022-v2:0"
      instruction                 = "do what the supervisor is asking you to do"
      collaboration_instruction   = "tell the other agent on what to do"
      alias_name                  = "TechSupport"
      description                 = "Collaborator 3"
      relay_conversation_history  = "TO_COLLABORATOR"
      prepare_agent               = true
      idle_session_ttl_in_seconds = 600
      action_groups               = local.action_groups_2
    }
  ]

  action_groups = [{
    name                       = "singlerulegenerationagent-actiongroup"
    state                      = "ENABLED"
    agent_version              = "DRAFT"
    skip_resource_in_use_check = true
    action_group_executor = { lambda = {
      name           = "arc-debug-budgets-default"
      add_permission = true
      }
    }

    function_schema = [
      {
        functions = [
          {
            name        = "extract_general_props"
            description = "Extracts general info properties based on the user prompt."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user instruction/prompt to create or edit the rule."
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "The existing rule to be updated, if provided."
                required      = false
              }
            ]
          },
          {
            name        = "extract_static_props"
            description = "Extracts static properties based on the user prompt."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user instruction/prompt to create or edit the rule."
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "The existing rule to be updated, if provided."
                required      = false
              }
            ]
          }
        ]
      }
    ]
  }]

  action_groups_2 = [{
    name                       = "singlerulegenerationagent-actiongroup-2"
    state                      = "ENABLED"
    agent_version              = "DRAFT"
    skip_resource_in_use_check = true
    action_group_executor = { lambda = {
      name           = "arc-debug-budgets-default"
      add_permission = true
      }
    }

    function_schema = [
      {
        functions = [
          {
            name        = "extract_general_props"
            description = "Extracts general info properties based on the user prompt."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user instruction/prompt to create or edit the rule."
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "The existing rule to be updated, if provided."
                required      = false
              }
            ]
          },
          {
            name        = "extract_static_props"
            description = "Extracts static properties based on the user prompt."
            parameters = [
              {
                map_block_key = "prompt"
                type          = "string"
                description   = "The user instruction/prompt to create or edit the rule."
                required      = true
              },
              {
                map_block_key = "rule_context"
                type          = "string"
                description   = "The existing rule to be updated, if provided."
                required      = false
              }
            ]
          }
        ]
      }
    ]
  }]



}
