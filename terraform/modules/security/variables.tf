variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Create the WAF Web ACL."
  type        = bool
  default     = false
}
