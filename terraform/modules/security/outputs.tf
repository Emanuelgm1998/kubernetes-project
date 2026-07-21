output "web_acl_arn" {
  description = "WAF Web ACL ARN."
  value       = try(aws_wafv2_web_acl.this[0].arn, null)
}
