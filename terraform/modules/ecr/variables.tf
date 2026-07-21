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

variable "force_delete" {
  description = "Delete repository images with the repository. Intended only for ephemeral non-production environments."
  type        = bool
  default     = false
}
