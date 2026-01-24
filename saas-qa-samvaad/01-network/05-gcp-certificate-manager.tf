# resource "google_certificate_manager_dns_authorization" "wildcard_auth" {
#   name        = "wildcard-auth"
#   domain      = "saas-qa-samvaad.sarvam.ai"
#   description = "The dns auth for wildcard domain"
# }

# resource "google_certificate_manager_certificate" "wildcard_cert" {
#   name        = "wildcard-cert"
#   description = "Wildcard cert for saas-qa"
#   scope       = "DEFAULT" # DEFAULT is for Global LB
#   managed {
#     domains = [
#       "saas-qa-samvaad.sarvam.ai",
#       "*.saas-qa-samvaad.sarvam.ai"
#     ]
#     dns_authorizations = [
#       google_certificate_manager_dns_authorization.wildcard_auth.id
#     ]
#   }
# }

# resource "google_certificate_manager_certificate_map" "cert_map" {
#   name = "kong-gateway-cert-map"
# }

# resource "google_certificate_manager_certificate_map_entry" "wildcard_entry" {
#   name         = "wildcard-entry"
#   map          = google_certificate_manager_certificate_map.cert_map.name
#   certificates = [google_certificate_manager_certificate.wildcard_cert.id]
#   hostname     = "*.saas-qa-samvaad.sarvam.ai"
# }