locals {
  samvaad_topics = [
    "v2v-scheduled-connected",
    "v2v-scheduled-not-connected",
    "v2v-unscheduled-connected",
    "chat-outbound",
    "chat-inbound",
    "runtime-scheduling-queue",
    "wa-runtime-scheduling-queue",
    "audio-ingestion-topic"
  ]
}

resource "kubernetes_manifest" "strimzi_topics" {
  for_each = toset(local.samvaad_topics)

  manifest = {
    "apiVersion" = "kafka.strimzi.io/v1beta2"
    "kind"       = "KafkaTopic"

    "metadata" = {
      "name"      = each.value
      "namespace" = "kafka"

      "labels" = {
        "strimzi.io/cluster" = "kafka-cluster"
      }
    }

    "spec" = {
      "partitions" = 10
      "replicas"   = 3

      "config" = {
        "retention.ms"        = 604800000 # 7 days
        "min.insync.replicas" = 2
      }
    }
  }
}

resource "kubernetes_config_map_v1" "kafka_bootstrap_config" {
  for_each = toset(local.namespaces)

  metadata {
    name      = "kafka-bootstrap-env"
    namespace = each.key
  }

  data = {
    "KAFKA_BOOTSTRAP_SERVERS" = "kafka-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092"
    "MESSAGE_BROKER_TYPE" = "kafka"
  }
}