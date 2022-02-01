resource "kubernetes_cluster_role" "ebs_external_provisioner_role" {
  metadata {
    name = "ebs-external-provisioner-role"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
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
    verbs      = ["get", "list"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }
}

