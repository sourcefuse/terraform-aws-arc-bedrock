##################################################
################ S3 Bucket #######################
##################################################

locals {
  s3_list = { for idx, obj in var.knowledge_base_config.data_storage_list : obj.s3_config.name => {
    name = obj.s3_config.name
    }
  if obj.type == "S3" && obj.s3_config.create }
}

module "s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.4"

  for_each = local.s3_list

  name = each.key
  acl  = "private"
  tags = var.tags
}

resource "opensearch_index" "this" {
  count = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.create ? 1 : 0

  name                           = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.vector_index_name
  number_of_shards               = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.number_of_shards
  number_of_replicas             = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.number_of_shards
  index_knn                      = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.index_knn
  index_knn_algo_param_ef_search = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.index_knn_algo_param_ef_search
  mappings                       = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.mappings == null ? local.opensearch_index_mapping : var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.index_config.mappings
  force_destroy                  = true
}
