output "network" {
  value       = module.vpc
  description = "The created network"
}

output "subnets" {
  value       = module.vpc.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "network_id" {
  value       = module.vpc.network_id
  description = "The ID of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc.network_self_link
  description = "The URI of the VPC being created"
}

output "project_id" {
  value       = module.vpc.project_id
  description = "VPC project id"
}

output "subnets_names" {
  value = { for subnet in module.vpc.subnets :
    subnet.name => subnet
  }
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = [for network in module.vpc.subnets : network.id]
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = [for network in module.vpc.subnets : network.ip_cidr_range]
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = [for network in module.vpc.subnets : network.self_link]
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = [for network in module.vpc.subnets : network.region]
  description = "The region where the subnets will be created"
}

output "subnets_private_access" {
  value       = [for network in module.vpc.subnets : network.private_ip_google_access]
  description = "Whether the subnets will have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = [for network in module.vpc.subnets : length(network.log_config) != 0 ? true : false]
  description = "Whether the subnets will have VPC flow logs enabled"
}

output "subnets_secondary_range" {

  value       = [for network in module.vpc.subnets : network.secondary_ip_range]
  description = "The secondary ranges associated with these subnets"
}

output "secondary_ranges_map" {
  value = {
    for range in flatten(module.vpc.subnets_secondary_ranges) :
    range.range_name => range.range_name
  }
}

output "gateway_ip_address" {
  value = google_compute_address.lb_gateway_ip.address
}

output "gateway_ip_name" {
  value = google_compute_address.lb_gateway_ip.name
}

output "dns_auth_record_name" {
  value = google_certificate_manager_dns_authorization.wildcard_auth.dns_resource_record[0].name
}

output "dns_auth_record_data" {
  value = google_certificate_manager_dns_authorization.wildcard_auth.dns_resource_record[0].data
}

output "kong_gateway_cert_map_name" {
  value = google_certificate_manager_certificate_map.cert_map.name
}
output "glb_cert_map_id" {
  value = google_certificate_manager_certificate_map.cert_map.id
}
