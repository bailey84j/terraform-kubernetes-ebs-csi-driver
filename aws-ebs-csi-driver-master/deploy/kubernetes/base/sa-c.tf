resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name = "ebs-csi-controller-sa"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }
}

