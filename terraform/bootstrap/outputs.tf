output "apply_role_arn" {
  value = aws_iam_role.oidc_apply_role.arn
}

output "plan_role_arn" {
  value = aws_iam_role.oidc_plan_role.arn
}

output "acm_cert_arn" {
  value = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
}

output "boundary_policy_arn" {
  value = aws_iam_policy.iam_boundary.arn
}