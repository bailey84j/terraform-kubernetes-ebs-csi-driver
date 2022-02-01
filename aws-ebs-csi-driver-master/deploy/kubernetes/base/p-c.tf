resource "kubernetes_pod_disruption_budget" "ebs_csi_controller" {
  metadata {
    name = "ebs-csi-controller"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ebs-csi-controller"

        "app.kubernetes.io/name" = "aws-ebs-csi-driver"
      }
    }

    max_unavailable = "1"
  }
}

