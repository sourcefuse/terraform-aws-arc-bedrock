output "opensearch_collection_endpoint" {
  value       = module.opensearch_serverless[0].opensearch_collection_endpoint
  description = "Opensearch Collection endpoint"
}
