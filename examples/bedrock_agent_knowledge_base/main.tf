################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "opensearch" {
  url         = module.bedrock_agent.opensearch_collection_endpoint
  healthcheck = false
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = "dev"
  project     = "terraform-aws-arc-bedrock"

  extra_tags = {
    Example = "True"
  }
}

module "bedrock_agent" {
  source = "../../"

  namespace   = "arc"
  environment = "dev"

  bedrock_agent_config = {
    create           = true
    name             = "arc-bedrock-agent-kb"
    foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    instruction      = "You are a customer support assistant. Answer user queries."
    prepare_agent    = true
    alias_name       = "arc-bedrock-agent-alias-kb"
  }

  knowledge_base_config = local.knowledge_base_config

  tags = module.tags.tags
}

// Role : AmazonBedrockExecutionRoleForKnowledgeBase_amoig
/*
Note:-
Currently, there is an issue when multiple collaborators are created simultaneously. To resolve this, use the `-parallelism=1` flag:
```hcl
terraform apply -parallelism=1
```

Other Option is to use individual module block for each colloborator agents

Error :
```
Prepare operation can't be performed on Agent when it is
│ in Preparing state. Retry the request when the agent is in a valid state.
```
*/
