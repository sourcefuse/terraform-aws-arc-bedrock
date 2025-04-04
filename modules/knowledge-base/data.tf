####################################################################
### Policy Documents for Knowledge base
####################################################################

data "aws_iam_policy_document" "bedrock_invoke_model" {
  statement {
    sid    = "BedrockInvokeModelStatement"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      var.knowledge_base_config.foundation_model_arn
    ]
  }
}

data "aws_iam_policy_document" "opensearch_serverless_api" {
  statement {
    sid    = "OpenSearchServerlessAPIAccessAllStatement"
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = [
      module.opensearch_serverless[0].opensearch_serverless_collection_arn
    ]
  }
}

locals {
  data_source_bucket_arns = [for s in module.data_source_s3 : s.bucket_arn]
  _data_source_bucket_arn = [for s in module.data_source_s3 : "${s.bucket_arn}/*"]

  data_storage_bucket_arns = [for s in module.data_storage_s3 : s.bucket_arn]
  _data_storage_bucket_arn = [for s in module.data_storage_s3 : "${s.bucket_arn}/*"]
}

data "aws_iam_policy_document" "data_source_s3_access" {
  statement {
    sid    = "S3ListBucketStatement"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = local.data_source_bucket_arns
  }

  statement {
    sid    = "S3GetObjectStatement"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = local._data_source_bucket_arn
  }
}

data "aws_iam_policy_document" "data_storage_s3_access" {
  statement {
    sid    = "S3ListBucketStatement"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = local.data_storage_bucket_arns
  }

  statement {
    sid    = "S3GetObjectStatement"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"

    ]
    resources = local._data_storage_bucket_arn
  }
}

data "aws_iam_policy_document" "agent_permission" {
  statement {
    actions = ["bedrock:Retrieve"]
    resources = [
      aws_bedrockagent_knowledge_base.this.arn
    ]
  }
}
