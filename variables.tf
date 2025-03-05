variable "bedrock_agent_config" {
  type = object({
    create                      = optional(bool, false)
    name                        = optional(string, null)
    idle_session_ttl_in_seconds = optional(number, 500)
    foundation_model            = optional(string, null)
    instruction                 = optional(string, null)
    agent_collaboration         = optional(string, "DISABLED")
    description                 = optional(string, null)
    prepare_agent               = optional(bool, true)
    role_arn                    = optional(string, null)
  })

  description = "Configuration for the Amazon Bedrock Agent, including name, session TTL, foundation model, tags, instructions, collaboration settings, and preparation options."

  validation {
    condition     = contains(["SUPERVISOR", "SUPERVISOR_ROUTER", "DISABLED"], var.bedrock_agent_config.agent_collaboration)
    error_message = "Invalid value for agent_collaboration. Allowed values: SUPERVISOR, SUPERVISOR_ROUTER, DISABLED."
  }

  validation {
    condition = (
      var.bedrock_agent_config.create == false ||
      (
        var.bedrock_agent_config.name != null && var.bedrock_agent_config.name != "" &&
        var.bedrock_agent_config.foundation_model != null && var.bedrock_agent_config.foundation_model != "" &&
        var.bedrock_agent_config.instruction != null && var.bedrock_agent_config.instruction != ""
      )
    )
    error_message = "If 'create' is true, 'name', 'foundation_model', and 'instruction' must be non-empty values."
  }

  default = {
    create = false
  }
}

variable "action_groups" {
  type = list(object({
    name                       = string
    state                      = string
    agent_version              = string
    skip_resource_in_use_check = optional(bool, true)
    action_group_executor      = object({ lambda = string })
    function_schema = list(object({
      functions = list(object({
        name        = string
        description = string
        parameters = list(object({
          map_block_key = string
          type          = string
          description   = string
          required      = bool
        }))
      }))
    }))

  }))
  description = "List of configurations for AWS Bedrock Agent Action Groups."
  default     = []
}


variable "agent_collaborator" {
  type = object({
    name                        = string
    supervisor_agent_id         = optional(string, null)
    collaborator_name           = optional(string, null)
    instruction                 = string
    collaboration_instruction   = string
    alias_name                  = string
    foundation_model            = string
    description                 = optional(string, "")
    relay_conversation_history  = optional(string, "TO_COLLABORATOR")
    prepare_agent               = optional(bool, true)
    idle_session_ttl_in_seconds = optional(number, 500)

    action_groups = optional(list(object({
      name                       = string
      state                      = string
      agent_version              = string
      skip_resource_in_use_check = optional(bool, true)
      action_group_executor = object(
        {
          lambda         = optional(string, null)
          custom_control = optional(string, null)
      })
      function_schema = list(object({
        functions = list(object({
          name        = string
          description = string
          parameters = list(object({
            map_block_key = string
            type          = string
            description   = string
            required      = bool
          }))
        }))
      }))

    })), [])
  })

  description = "Configuration object for a collaborator, including name, instructions, and settings."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags for Bedrock resources"
  default     = {}
}
