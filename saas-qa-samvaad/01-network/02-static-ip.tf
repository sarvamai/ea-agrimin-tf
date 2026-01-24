resource "google_compute_address" "nat_ip" {
  name    = "nat-services-base-static-ip-0"
  region  = local.region
  project = local.project_id
}

resource "google_compute_address" "lb_gateway_ip" {
  name         = "regional-gateway-ip"
  region       = "asia-south1"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}
