variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
}

variable "cluster_name" {
  description = "ECS Cluster name for CloudWatch alarms"
  type        = string
}

variable "service_name" {
  description = "ECS Service name for CloudWatch alarms"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target Group ARN suffix for CloudWatch metrics"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch Log Group name for metric filters"
  type        = string
}

variable "alert_email" {
  description = "Email address for SNS notifications (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
