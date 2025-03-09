variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. arc"
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
    foundation_model_arn = string
    description          = optional(string, null)
    agent_id             = string
    instruction          = string
    data_source_list = list(object({
      type = optional(string, "S3")
      s3_config = optional(object({
        create             = optional(bool, false)
        name               = string
        inclusion_prefixes = optional(list(string), [])
      }))
    }))
    data_storage_list = list(object({
      type = optional(string, "S3")
      s3_config = optional(object({
        create = optional(bool, false)
        prefix = optional(string, "")
        name   = string
      }))
    }))
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
}
