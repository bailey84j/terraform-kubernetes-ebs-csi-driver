resource "kubernetes_cluster_role" "ebs_external_snapshotter_role" {
  metadata {
    name = "ebs-external-snapshotter-role"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  rule {
    verbs      = ["list", "watch", "create", "update", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "update", "delete"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
  }
}

