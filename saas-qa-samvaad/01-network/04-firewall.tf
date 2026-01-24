
module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = local.project_id
  network_name = module.vpc.network_name

  rules = [
    {
      name        = "allow-iap-ssh"
      description = "Allow SSH from IAP"
      direction   = "INGRESS"
      ranges      = ["35.235.240.0/20"] # Google IAP Range
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    {
      name        = "allow-internal-traffic"
      description = "Allow all traffic between internal subnets"
      direction   = "INGRESS"
      ranges      = ["10.0.0.0/8"]
      allow = [{
        protocol = "icmp"
        }, {
        protocol = "tcp"
        }, {
        protocol = "udp"
      }]
    }
  ]
}