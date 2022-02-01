resource "kubernetes_cluster_role" "ebs_external_resizer_role" {
  metadata {
    name = "ebs-external-resizer-role"

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
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }

  rule {
    verbs      = ["list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }
}

