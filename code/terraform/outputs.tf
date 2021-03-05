# Keep all output variables

output "active_version" {
  value = fastly_service_v1.fastly-service.active_version
  depends_on = [ fastly_service_v1.fastly-service ]
}

output "cloned_version" {
  value = fastly_service_v1.fastly-service.cloned_version
  depends_on = [ fastly_service_v1.fastly-service ]
}

output "service_id" {
  value = fastly_service_v1.fastly-service.id
  depends_on = [ fastly_service_v1.fastly-service ]
}