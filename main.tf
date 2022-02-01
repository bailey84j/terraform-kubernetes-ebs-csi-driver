# region kubernetes resources
resource "kubernetes_namespace" "this" {
  count = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? 1 : 0
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

data "kubernetes_namespace" "this" {
  count = !var.create_namespace || contains(local.default_namespaces, var.namespace) ? 1 : 0
  metadata {
    name = var.namespace
  }
}

# namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
# region kubernetes cluster roles

resource "kubernetes_cluster_role" "ebs_external_attacher_role" {
  metadata {
    name = "ebs-external-attacher-role"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
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

resource "kubernetes_cluster_role" "ebs_csi_node_role" {
  metadata {
    name = "ebs-csi-node-role"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }
}

resource "kubernetes_cluster_role" "ebs_external_provisioner_role" {
  metadata {
    name = "ebs-external-provisioner-role"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
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

resource "kubernetes_cluster_role" "ebs_external_resizer_role" {
  metadata {
    name = "ebs-external-resizer-role"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
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

resource "kubernetes_cluster_role" "ebs_external_snapshotter_role" {
  metadata {
    name = "ebs-external-snapshotter-role"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
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

# endregion kubernetes cluster roles
# region kubernetes cluster role bindings

resource "kubernetes_cluster_role_binding" "ebs_csi_attacher_binding" {
  metadata {
    name = "ebs-csi-attacher-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-controller-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-attacher-role"
  }
}

resource "kubernetes_cluster_role_binding" "ebs_csi_node_getter_binding" {
  metadata {
    name = "ebs-csi-node-getter-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-node-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-csi-node-role"
  }
}

resource "kubernetes_cluster_role_binding" "ebs_csi_provisioner_binding" {
  metadata {
    name = "ebs-csi-provisioner-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-controller-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-provisioner-role"
  }
}

resource "kubernetes_cluster_role_binding" "ebs_csi_resizer_binding" {
  metadata {
    name = "ebs-csi-resizer-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-controller-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-resizer-role"
  }
}

resource "kubernetes_cluster_role_binding" "ebs_csi_snapshotter_binding" {
  metadata {
    name = "ebs-csi-snapshotter-binding"

    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.name}-controller-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-snapshotter-role"
  }
}

# endregion kubernetes cluster role bindings
# region kubernetes service accounts
resource "kubernetes_service_account" "this_controller_sa" {
  metadata {
    name      = "${var.name}-controller-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_service_account" "this_node_sa" {
  metadata {
    name      = "${var.name}-node-sa"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# endregion kubernetes service accounts
# region kubernetes deployments
resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    name = "ebs-csi-controller"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "ebs-csi-controller"

        "app.kubernetes.io/name" = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = "ebs-csi-controller"

          "app.kubernetes.io/name" = var.name
        }
      }

      spec {
        volume {
          name = "socket-dir"
          empty_dir {}
        }

        container {
          name  = "ebs-plugin"
          image = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver:v1.5.0"
          args  = ["--endpoint=$(CSI_ENDPOINT)", "--logtostderr", "--v=2"]

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "AWS_ACCESS_KEY_ID"

            value_from {
              secret_key_ref {
                name     = "aws-secret"
                key      = "key_id"
                optional = true
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"

            value_from {
              secret_key_ref {
                name     = "aws-secret"
                key      = "access_key"
                optional = true
              }
            }
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-provisioner"
          image = "k8s.gcr.io/sig-storage/csi-provisioner:v2.1.1"
          args  = ["--csi-address=$(ADDRESS)", "--v=2", "--feature-gates=Topology=true", "--extra-create-metadata", "--leader-election=true", "--default-fstype=ext4"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-attacher"
          image = "k8s.gcr.io/sig-storage/csi-attacher:v3.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--v=2", "--leader-election=true"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-snapshotter"
          image = "k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3"
          args  = ["--csi-address=$(ADDRESS)", "--leader-election=true"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "csi-resizer"
          image = "k8s.gcr.io/sig-storage/csi-resizer:v1.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--v=2"]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "liveness-probe"
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.4.0"
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/csi"
          }

          image_pull_policy = "IfNotPresent"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "${var.name}-controller-sa"

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          operator           = "Exists"
          effect             = "NoExecute"
          toleration_seconds = 300
        }

        priority_class_name = "system-cluster-critical"
      }
    }
  }
}

resource "kubernetes_daemonset" "ebs_csi_node" {
  metadata {
    name = "ebs-csi-node"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ebs-csi-node"

        "app.kubernetes.io/name" = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = "ebs-csi-node"

          "app.kubernetes.io/name" = var.name
        }
      }

      spec {
        volume {
          name = "kubelet-dir"

          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }

        volume {
          name = "plugin-dir"

          host_path {
            path = "/var/lib/kubelet/plugins/ebs.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "registration-dir"

          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
        }

        volume {
          name = "device-dir"

          host_path {
            path = "/dev"
            type = "Directory"
          }
        }

        container {
          name  = "ebs-plugin"
          image = "k8s.gcr.io/provider-aws/aws-ebs-csi-driver:v1.5.0"
          args  = ["node", "--endpoint=$(CSI_ENDPOINT)", "--logtostderr", "--v=2"]

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
          }

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name              = "kubelet-dir"
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name       = "device-dir"
            mount_path = "/dev"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 10
            failure_threshold     = 5
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            privileged = true
          }
        }

        container {
          name  = "node-driver-registrar"
          image = "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.1.0"
          args  = ["--csi-address=$(ADDRESS)", "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)", "--v=2"]

          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }

          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/ebs.csi.aws.com/csi.sock"
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          volume_mount {
            name       = "registration-dir"
            mount_path = "/registration"
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name  = "liveness-probe"
          image = "k8s.gcr.io/sig-storage/livenessprobe:v2.4.0"
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }

          image_pull_policy = "IfNotPresent"
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "${var.name}-node-sa"

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }
              }
            }
          }
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          operator           = "Exists"
          effect             = "NoExecute"
          toleration_seconds = 300
        }

        priority_class_name = "system-node-critical"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "10%"
      }
    }
  }
}

# endregion kubernetes deployments

resource "kubernetes_pod_disruption_budget" "this" {
  metadata {
    name      = "${var.name}-controller"
    namespace = var.create_namespace && !contains(local.default_namespaces, var.namespace) ? kubernetes_namespace.this[0].metadata[0].name : data.kubernetes_namespace.this[0].metadata[0].name

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ebs-csi-controller"

        "app.kubernetes.io/name" = var.name
      }
    }

    max_unavailable = "1"
  }
}

resource "kubernetes_csi_driver" "this" {
  metadata {
    name = "ebs.csi.aws.com"

    labels = {
      "app.kubernetes.io/name" = var.name
    }
  }

  spec {
    attach_required = true
    volume_lifecycle_modes = ["Persistent"]
  }
}
# endregion Kubernetes Resources
# region aws resources
# region aws iam role

locals {
  iam_role_name = coalesce(var.iam_role_name, "${var.eks_cluster_name}-${var.name}")
}
# to be updated
data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.namespace}:${var.name}-node-sa",
        "system:serviceaccount:${var.namespace}:${var.name}-controller-sa"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.target.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}${var.prefix_separator}" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  inline_policy {
    name = "ebs-csi-driver"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateSnapshot",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "ec2:ModifyVolume",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeInstances",
            "ec2:DescribeSnapshots",
            "ec2:DescribeTags",
            "ec2:DescribeVolumes",
            "ec2:DescribeVolumesModifications"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:CreateAction" : [
                "CreateVolume",
                "CreateSnapshot"
              ]
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteTags"
          ],
          "Resource" : [
            "arn:aws:ec2:*:*:volume/*",
            "arn:aws:ec2:*:*:snapshot/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:RequestTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:RequestTag/CSIVolumeName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "aws:RequestTag/kubernetes.io/cluster/*" : "owned"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/CSIVolumeName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteVolume"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/kubernetes.io/cluster/*" : "owned"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteSnapshot"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/CSIVolumeSnapshotName" : "*"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DeleteSnapshot"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/ebs.csi.aws.com/cluster" : "true"
            }
          }
        }
      ]
    })
  }

  managed_policy_arns = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"]

  tags = merge(var.tags, var.iam_role_tags)

}

# endregion aws iam role
# endregion aws resources
