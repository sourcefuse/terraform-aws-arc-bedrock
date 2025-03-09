locals {

  knowledge_base_config = {
    create               = true
    name                 = "arc-dev-knowledge-base"
    foundation_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
    description          = "A knowledge base for AI-driven search"
    instruction          = "Terraform deployed Knowledge Base"

    data_source_list = [
      {
        type = "S3"
        s3_config = {
          create             = true
          name               = "arc-dev-knowledge-base"
          inclusion_prefixes = ["data/"]
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
        name                        = "arc-dev-knowledge-base-os"
        access_policy_rules         = []
        data_lifecycle_policy_rules = []

        opensearch_index_mapping = local.opensearch_index_mapping
        index_config = {
          number_of_shards               = "2"
          number_of_replicas             = "0"
          index_knn                      = true
          index_knn_algo_param_ef_search = "512"
        }

        vector_index_name = "arc-dev-knowledge-base-index"

        field_mapping = {
          vector_field   = "bedrock-knowledge-base-default-vector"
          text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
          metadata_field = "AMAZON_BEDROCK_METADATA"
        }
      }
    }
  }


  opensearch_index_mapping = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1024,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF

}
