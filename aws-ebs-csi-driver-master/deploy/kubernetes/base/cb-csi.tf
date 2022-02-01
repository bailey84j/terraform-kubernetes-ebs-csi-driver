resource "kubernetes_cluster_role_binding" "ebs_csi_node_getter_binding" {
  metadata {
    name = "ebs-csi-node-getter-binding"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ebs-csi-node-sa"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-csi-node-role"
  }
}

