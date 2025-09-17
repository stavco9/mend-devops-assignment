output "kubernetes_master_policies" {
  value = [local.ssm_policy]
}

output "kubernetes_nodes_policies" {
  value = [local.ssm_policy]
}

output "aws_load_balancer_controller_policy" {
  value = aws_iam_policy.load_balancer_controller_policy.arn
}

output "external_dns_policy" {
  value = aws_iam_policy.external_dns_policy.arn
}