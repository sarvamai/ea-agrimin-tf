resource "google_compute_router" "router" {
  name    = "${local.env_prefix}-router"
  region  = local.region
  network = module.vpc.network_name
  project = local.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.env_prefix}-nat"
  router                             = google_compute_router.router.name
  region                             = local.region
  project                            = local.project_id
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}