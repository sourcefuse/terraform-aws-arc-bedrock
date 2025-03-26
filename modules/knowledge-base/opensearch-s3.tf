##################################################
################ S3 Bucket #######################
##################################################

locals {
  data_source_s3_list = { for idx, obj in var.knowledge_base_config.data_source_list : obj.s3_config.name => {
    name = obj.s3_config.name
    }
  if obj.type == "S3" && obj.s3_config.create }

  data_storage_s3_list = { for idx, obj in var.knowledge_base_config.data_storage_list : obj.s3_config.name => {
    name = obj.s3_config.name
    }
  if obj.type == "S3" && obj.s3_config.create }


}

# ##################################################
# ######## OpenSearch Serverless Domain  ###########
# ##################################################
module "opensearch_serverless" {
  source  = "sourcefuse/arc-opensearch/aws"
  version = "1.0.5"

  count = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.create ? 1 : 0

  enable_serverless           = true
  type                        = "VECTORSEARCH"
  namespace                   = var.namespace
  environment                 = var.environment
  name                        = var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.name
  enable_public_access        = true
  data_lifecycle_policy_rules = local.data_lifecycle_policy_rules
  access_policy_rules         = local.access_policy_rules
  use_standby_replicas        = false
  tags                        = var.tags
}

module "data_source_s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.4"

  for_each = local.data_source_s3_list

  name = each.key
  acl  = "private"
  tags = var.tags
}

module "data_storage_s3" {
  source  = "sourcefuse/arc-s3/aws"
  version = "0.0.4"

  for_each = local.data_storage_s3_list

  name = each.key
  acl  = "private"
  tags = var.tags
}


// Workaround for  "Error: elastic: Error 401 (Unauthorized)""
resource "time_sleep" "wait_20_seconds" {
  depends_on = [module.opensearch_serverless]

  create_duration = "30s"
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
  depends_on                     = [time_sleep.wait_20_seconds]
}
