variable "collaborator_name" {
  type        = string
  description = "(optional) Collaborator name"
  default     = null
}

variable "supervisor_agent_id" {
  type        = string
  description = "Supervisor Agent ID"
}

variable "collaboration_instruction" {
  type        = string
  description = "Instruction to give the collaborator."
}

variable "alias_name" {
  type        = string
  description = "Alias name of the collaborator."
}

variable "description" {
  type        = string
  default     = ""
  description = "(Optional) Description of the collaborator."
}

variable "relay_conversation_history" {
  type        = string
  default     = "TO_COLLABORATOR"
  description = "(Optional) Specifies whether to relay conversation history. Default is 'TO_COLLABORATOR'."
}

variable "collaborator_agent_id" {
  type        = string
  description = "Collaborator agent id"
}

variable "collaborator_agent_arn" {
  type        = string
  description = "Collaborator agent arn"
}

variable "tags" {
  type        = map(string)
  description = "Tags for Bedrock resources"
  default     = {}
}

variable "action_groups" {
  type = list(object({
    name                       = string
    state                      = string
    agent_version              = string
    skip_resource_in_use_check = optional(bool, true)
    action_group_executor = object(
      {
        lambda = optional(object({
          name           = string
          add_permission = optional(bool, true)
        }))
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
  }))
  description = "List of configurations for AWS Bedrock Agent Action Groups."
  default     = []
}
