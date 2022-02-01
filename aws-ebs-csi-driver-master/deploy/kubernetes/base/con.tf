resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    name = "ebs-csi-controller"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "ebs-csi-controller"

        "app.kubernetes.io/name" = "aws-ebs-csi-driver"
      }
    }

    template {
      metadata {
        labels = {
          app = "ebs-csi-controller"

          "app.kubernetes.io/name" = "aws-ebs-csi-driver"
        }
      }

      spec {
        volume {
          name      = "socket-dir"
          empty_dir = {}
        }

        container {
          name  = "ebs-plugin"
          image = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver:v1.5.0"
          args  = ["--endpoint=$(CSI_ENDPOINT)", "--logtostderr", "--v=2"]

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "AWS_ACCESS_KEY_ID"

            value_from {
              secret_key_ref {
                name     = "aws-secret"
                key      = "key_id"
                optional = true
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"

            value_from {
              secret_key_ref {
                name     = "aws-secret"
                key      = "access_key"
                optional = true
              }
            }
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-provisioner"
          image = "k8s.gcr.io/sig-storage/csi-provisioner:v2.1.1"
          args  = ["--csi-address=$(ADDRESS)", "--v=2", "--feature-gates=Topology=true", "--extra-create-metadata", "--leader-election=true", "--default-fstype=ext4"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-attacher"
          image = "k8s.gcr.io/sig-storage/csi-attacher:v3.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--v=2", "--leader-election=true"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-snapshotter"
          image = "k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3"
          args  = ["--csi-address=$(ADDRESS)", "--leader-election=true"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-resizer"
          image = "k8s.gcr.io/sig-storage/csi-resizer:v1.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--v=2"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "liveness-probe"
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.4.0"
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }

          image_pull_policy = "IfNotPresent"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ebs-csi-controller-sa"

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          operator           = "Exists"
          effect             = "NoExecute"
          toleration_seconds = 300
        }

        priority_class_name = "system-cluster-critical"
      }
    }
  }
}

