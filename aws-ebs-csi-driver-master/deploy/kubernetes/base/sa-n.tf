resource "kubernetes_service_account" "ebs_csi_node_sa" {
  metadata {
    name = "ebs-csi-node-sa"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }
}

