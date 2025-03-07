data "aws_caller_identity" "current" {}
locals {
  name = "${var.namespace}-${var.environment}-opensearch"

  ## OpenSearch Serverless Domain
  access_policy_rules = [
    {
      resource_type = "collection"
      resource      = ["collection/${local.name}"]
      permissions   = ["aoss:CreateCollectionItems", "aoss:DeleteCollectionItems", "aoss:UpdateCollectionItems", "aoss:DescribeCollectionItems"]
      principal     = [data.aws_caller_identity.current.arn]
    },
    {
      resource_type = "index"
      resource      = ["index/${local.name}/*"]
      permissions   = ["aoss:UpdateIndex", "aoss:DescribeIndex", "aoss:ReadDocument", "aoss:WriteDocument", "aoss:CreateIndex"]
      principal     = [data.aws_caller_identity.current.arn]
    }
  ]

  data_lifecycle_policy_rules = [
    {
      indexes   = ["index1", "index2"]
      retention = "30d"
    },
    {
      indexes   = ["index3"]
      retention = "24h"
    }
  ]


  knowledge_base_config = {
    create           = true
    name             = "arc-dev-knowledge-base"
    foundation_model = "amazon.titan-embed-text-v2:0"
    description      = "A knowledge base for AI-driven search"

    data_storage_list = [
      {
        type = "S3"
        s3_config = {
          create = true
          prefix = "data/"
          name   = "arc-dev-knowledge-base"
        }
      }
    ]

    embedding_model_configuration = {
      dimensions          = 1024
      embedding_data_type = "FLOAT32"
    }

    storage_configuration = {
      type = "OPENSEARCH_SERVERLESS"
      opensearch_serverless_configuration = {
        create                      = true
        collection_arn              = module.opensearch_serverless.opensearch_serverless_collection_arn
        access_policy_rules         = []
        data_lifecycle_policy_rules = []

        index_config = {
          number_of_shards               = "2"
          number_of_replicas             = "0"
          index_knn                      = true
          index_knn_algo_param_ef_search = "512"
        }

        vector_index_name = "arc-dev-knowledge-base-index"

        field_mapping = {
          vector_field   = "vector_embeddings"
          text_field     = "text_content"
          metadata_field = "metadata_info"
        }
      }
    }
  }


}
