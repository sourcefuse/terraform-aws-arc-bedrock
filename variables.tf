variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. arc"
}

variable "bedrock_agent_config" {
  type = object({
    create                      = optional(bool, false)
    name                        = optional(string, null)
    alias_name                  = optional(string, null)
    alias_description           = optional(string, null)
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

variable "knowledge_base_config" {
  type = object({
    create               = optional(bool, false)
    name                 = string
    role_arn             = optional(string, null)
    agent_role_name      = optional(string, null)
    foundation_model_arn = string
    description          = optional(string, null)
    agent_id             = optional(string, null)
    instruction          = string
    data_source_list = list(object({
      type = optional(string, "S3")
      s3_config = optional(object({
        create             = optional(bool, false)
        name               = string
        inclusion_prefixes = optional(list(string), [])
      }))
    }))
    data_storage_list = optional(list(object({
      type = optional(string, "S3")
      s3_config = optional(object({
        create = optional(bool, false)
        prefix = optional(string, "")
        name   = string
      }))
    })), [])
    embedding_model_configuration = object({
      dimensions          = optional(number, 1024)
      embedding_data_type = string
    })
    storage_configuration = object({
      type = optional(string, "OPENSEARCH_SERVERLESS")
      opensearch_serverless_configuration = object({
        create                      = optional(bool, false)
        name                        = optional(string, null)
        collection_arn              = optional(string, null)
        access_policy_rules         = optional(list(any), [])
        data_lifecycle_policy_rules = optional(list(any), [])
        index_config = object({
          number_of_shards               = optional(string, "2")
          number_of_replicas             = optional(string, "0")
          index_knn                      = optional(bool, true)
          index_knn_algo_param_ef_search = optional(string, "512")
          mappings                       = optional(string, null)
        })
        vector_index_name = string
        field_mapping = object({
          vector_field   = string
          text_field     = string
          metadata_field = string
        })
      })
    })
  })


  description = "Configuration for AWS Bedrock Agent Knowledge Base, including vector storage, embedding model, and OpenSearch integration."
  default = {
    create                        = false
    name                          = null
    instruction                   = null
    foundation_model_arn          = null
    data_storage_list             = []
    embedding_model_configuration = null
    storage_configuration         = null
    data_source_list              = []
  }
}
