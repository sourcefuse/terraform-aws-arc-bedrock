data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "this" {
  count = 1
  name  = "${var.knowledge_base_config.name}-bedrock-knowledge-base-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AmazonBedrockKnowledgeBaseTrustPolicy"
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy" "bedrock_policy" {
  count = 1
  name  = "${var.knowledge_base_config.name}-bedrock-invoke-policy"
  role  = aws_iam_role.this[0].id

  policy = data.aws_iam_policy_document.bedrock_invoke_model.json
}

resource "aws_iam_role_policy" "opensearch_policy" {
  count = 1
  name  = "${var.knowledge_base_config.name}-opensearch-access-policy"
  role  = aws_iam_role.this[0].id

  policy = data.aws_iam_policy_document.opensearch_serverless_api.json
}

resource "aws_iam_role_policy" "s3_policy" {
  count = 1
  name  = "${var.knowledge_base_config.name}-s3-access-policy"
  role  = aws_iam_role.this[0].id

  policy = data.aws_iam_policy_document.s3_access.json
}

## Add permission for KB to Agent
resource "aws_iam_role_policy" "kb_permission" {
  policy = data.aws_iam_policy_document.agent_permission.json
  role   = var.knowledge_base_config.agent_role_name
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = var.knowledge_base_config.name
  role_arn = aws_iam_role.this[0].arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.knowledge_base_config.foundation_model_arn

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = var.knowledge_base_config.embedding_model_configuration.dimensions
          embedding_data_type = var.knowledge_base_config.embedding_model_configuration.embedding_data_type
        }
      }

      # supplemental_data_storage_configuration {

      #   dynamic "storage_location" {
      #     for_each = var.knowledge_base_config.data_storage_list

      #     content {
      #       type = storage_location.value.type

      #       s3_location {
      #         uri = "s3://${module.s3[storage_location.value.s3_config.name].bucket_id}/${storage_location.value.s3_config.prefix}"
      #       }
      #     }
      #   }
      # }


    }
    type = "VECTOR"

  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = module.opensearch_serverless[0].opensearch_serverless_collection_arn
      vector_index_name = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.vector_index_name
      field_mapping {
        vector_field   = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.field_mapping.vector_field
        text_field     = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.field_mapping.text_field
        metadata_field = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.field_mapping.metadata_field
      }
    }
  }

  depends_on = [opensearch_index.this]
}


resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = "${var.knowledge_base_config.name}-ds"

  dynamic "data_source_configuration" {
    for_each = var.knowledge_base_config.data_source_list
    content {
      type = "S3"
      s3_configuration {
        bucket_arn         = module.s3[data_source_configuration.value.s3_config.name].bucket_arn
        inclusion_prefixes = data_source_configuration.value.s3_config.inclusion_prefixes
      }
    }
  }
}

resource "aws_bedrockagent_agent_knowledge_base_association" "this" {
  agent_id             = var.knowledge_base_config.agent_id
  description          = var.knowledge_base_config.instruction
  knowledge_base_id    = aws_bedrockagent_knowledge_base.this.id
  knowledge_base_state = "ENABLED"

}
