resource "kubernetes_cluster_role" "ebs_external_attacher_role" {
  metadata {
    name = "ebs-external-attacher-role"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["csi.storage.k8s.io"]
    resources  = ["csinodeinfos"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments/status"]
  }
}

