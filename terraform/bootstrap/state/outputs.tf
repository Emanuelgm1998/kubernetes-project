output "state_bucket_name" {
  description = "S3 bucket name to place in environments/dev/backend.hcl."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_kms_key_arn" {
  description = "KMS key ARN to place in environments/dev/backend.hcl."
  value       = aws_kms_key.terraform_state.arn
}
