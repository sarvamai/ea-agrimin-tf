resource "kubernetes_manifest" "sarvam_app_runtime_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-app-runtime-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-app-runtime-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "sarvam_app_authoring_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-app-authoring-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-app-authoring-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "sarvam_app_scheduling_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-app-scheduling-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-app-scheduling-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "data_analyst_runtime_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "data-analyst-runtime-db"
      namespace = "postgres"
    }
    spec = {
      name  = "data-analyst-runtime-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "sarvam_app_eval_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-app-eval-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-app-eval-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "auth_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "auth-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "auth-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "kb_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "knowledge-base-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "knowledge-base-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "org_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "org-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "org-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "sarvam_app_analytics_service_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-app-analytics-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-app-analytics-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}

resource "kubernetes_manifest" "flagsmith_database" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = "sarvam-flagsmith-service-db"
      namespace = "postgres"
    }
    spec = {
      name  = "sarvam-flagsmith-service-db"
      owner = "samvaad"
      cluster = {
        name = "postgres-cluster"
      }
    }
  }
}