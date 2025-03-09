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
  url         = "null"
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


// This created Bedrock Superviset Agent and a Colloborator Agent
module "bedrock_agent" {
  source = "../../"

  bedrock_agent_config = {
    create              = true
    name                = "arc-bedrock-agent"
    foundation_model    = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    instruction         = "You are a customer support assistant. Answer user queries."
    agent_collaboration = "SUPERVISOR"
    prepare_agent       = false
    description         = "Supervisor agent"
    //alias_name          = "arc-bedrock-agent-alias"
  }
  agent_collaborator = {
    name                        = "collab-1"
    collaborator_name           = "Collaborator-One"
    foundation_model            = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    instruction                 = "do what the supervisor is asking you to do"
    collaboration_instruction   = "tell the other agent on what to do"
    alias_name                  = "DocProcessor"
    description                 = "Collaborator 1"
    relay_conversation_history  = "TO_COLLABORATOR"
    prepare_agent               = true
    idle_session_ttl_in_seconds = 600
  }

  tags = module.tags.tags

}

module "collaborator_agent_1" {
  source = "../../"

  for_each = { for idx, collaborator in local.collaborators : collaborator.name => collaborator }

  agent_collaborator = each.value
  tags               = module.tags.tags
}

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
