resource "kubernetes_config_map_v1" "storage_urls" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "storage-urls"
    namespace = each.key
  }
  data = {
    "app-storage-url"                           = "gs://${local.env_prefix}-moa-app-storage/apps"
    "sarvam-app-storage-url"                    = "gs://${local.env_prefix}-moa-app-storage"
    "runtime_cache_storage_url"                 = "gs://${local.env_prefix}-moa-app-storage/runtime-cache/"
    "pre-tts-elevenlabs-preprocessing-url"      = "gs://${local.env_prefix}-moa-app-storage/elevenlabs_tts_pronunciation_overrides/"
    "runtime_failed_events_storage_url"         = "gs://${local.env_prefix}-moa-app-storage/failed-events/"
    "sarvam-tts-voice-storage-url"              = "gs://${local.env_prefix}-moa-app-storage/speakers/"
    "asset-storage-url"                         = "gs://${local.env_prefix}-moa-app-storage/assets/"
    "auth-storage-url"                          = "gs://${local.env_prefix}-moa-app-storage/auth/"
    "sarvam-runtime-widgets-public-storage-url" = "gs://${local.env_prefix}-publicaccess/runtime-widgets-media/media/"
    "files-storage-url"                         = "gs://${local.env_prefix}-kb-storage/files/"
    "bulk-upload-storage-v1-url"                = "gs://${local.env_prefix}-publicaccess/bulk-upload-storage/jobs/"
    "kb-storage-url"                            = "gs://${local.env_prefix}-kb-storage/knowledge-base/"
    "pre-tts-preprocessing-url"                 = "gs://${local.env_prefix}-moa-app-storage/tts_pronunciation_overrides/"
    "public-session-storage-url"                = "gs://${local.env_prefix}-publicaccess/moa-app-storage/apps/"
    "regression-test-url"                       = "gs://${local.env_prefix}-moa-app-storage/regression-tests/"
    "session-storage-url"                       = "gs://${local.env_prefix}-moa-app-storage/apps/"
    "storage-url-prefix"                        = "gs://${local.env_prefix}-moa-app-storage"
    "template-storage-url"                      = "gs://${local.env_prefix}-moa-app-storage/default_templates/"
    "temporal-storage-url"                      = "gs://${local.env_prefix}-moa-app-storage/workflows/"
  }
}