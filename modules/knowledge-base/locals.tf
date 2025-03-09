locals {

  access_policy_rules = [
    {
      resource_type = "collection"
      resource      = ["collection/${var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.name}"]
      permissions   = ["aoss:CreateCollectionItems", "aoss:DeleteCollectionItems", "aoss:UpdateCollectionItems", "aoss:DescribeCollectionItems"]
      principal     = [data.aws_caller_identity.current.arn, aws_iam_role.this[0].arn]
    },
    {
      resource_type = "index"
      resource      = ["index/${var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.name}/*"]
      permissions   = ["aoss:UpdateIndex", "aoss:DescribeIndex", "aoss:ReadDocument", "aoss:WriteDocument", "aoss:CreateIndex", "aoss:DeleteIndex"]
      principal     = [data.aws_caller_identity.current.arn, aws_iam_role.this[0].arn]
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
