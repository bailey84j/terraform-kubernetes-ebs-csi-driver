resource "kubernetes_csi_driver" "ebs.csi.aws.com" {
  metadata {
    name = "ebs.csi.aws.com"

    labels = {
      "app.kubernetes.io/name" = "aws-ebs-csi-driver"
    }
  }

  spec {
    attach_required = true
  }
}

