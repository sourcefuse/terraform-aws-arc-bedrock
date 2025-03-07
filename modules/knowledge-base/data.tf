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
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.knowledge_base_config.foundation_model}"
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
      var.knowledge_base_config.storage_configuration.opensearch_serverless_configuration.collection_arn
    ]
  }
}

locals {
  bucket_arns = [for s in module.s3 : s.bucket_arn]
  _bucket_arn = [for s in module.s3 : "${s.bucket_arn}/*"]
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "S3ListBucketStatement"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = local.bucket_arns
  }

  statement {
    sid    = "S3GetObjectStatement"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = local._bucket_arn
  }
}
