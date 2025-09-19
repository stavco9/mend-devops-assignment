resource "aws_iam_role" "irsa_role" {
  name_prefix = substr("irsa-${var.cluster_name}-${var.irsa_role_name}", 0, 32)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
            "${var.oidc_provider_name}:sub" = "system:serviceaccount:${var.kubernetes_sa_namespace}:${var.kubernetes_sa_name}"
            "${var.oidc_provider_name}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa_role_policy_attachment" {
  for_each = toset(var.irsa_role_policies_arns)
  
  role = aws_iam_role.irsa_role.name
  policy_arn = each.value
}