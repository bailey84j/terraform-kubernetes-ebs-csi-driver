resource "kubernetes_cluster_role" "ebs_csi_node_role" {
  metadata {
    name = "ebs-csi-node-role"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

