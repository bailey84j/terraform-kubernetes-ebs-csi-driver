resource "kubernetes_cluster_role_binding" "ebs_csi_provisioner_binding" {
  metadata {
    name = "ebs-csi-provisioner-binding"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ebs-csi-controller-sa"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-provisioner-role"
  }
}
