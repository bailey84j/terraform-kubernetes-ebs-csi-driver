resource "kubernetes_daemonset" "ebs_csi_node" {
  metadata {
    name = "ebs-csi-node"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ebs-csi-node"

        "app.kubernetes.io/name" = "aws-ebs-csi-driver"
      }
    }

    template {
      metadata {
        labels = {
          app = "ebs-csi-node"

          "app.kubernetes.io/name" = "aws-ebs-csi-driver"
        }
      }

      spec {
        volume {
          name = "kubelet-dir"

          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }

        volume {
          name = "plugin-dir"

          host_path {
            path = "/var/lib/kubelet/plugins/ebs.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "registration-dir"

          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
        }

        volume {
          name = "device-dir"

          host_path {
            path = "/dev"
            type = "Directory"
          }
        }

        container {
          name  = "ebs-plugin"
          image = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver:v1.5.0"
          args  = ["node", "--endpoint=$(CSI_ENDPOINT)", "--logtostderr", "--v=2"]

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name              = "kubelet-dir"
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name       = "device-dir"
            mount_path = "/dev"
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

          image_pull_policy = "IfNotPresent"

          security_context {
            privileged = true
          }
        }

        container {
          name  = "node-driver-registrar"
          image = "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)", "--v=2"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/ebs.csi.aws.com/csi.sock"
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name       = "registration-dir"
            mount_path = "/registration"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "liveness-probe"
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.4.0"
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          image_pull_policy = "IfNotPresent"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ebs-csi-node-sa"

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }
              }
            }
          }
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          operator           = "Exists"
          effect             = "NoExecute"
          toleration_seconds = 300
        }

        priority_class_name = "system-node-critical"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "10%"
      }
    }
  }
}

