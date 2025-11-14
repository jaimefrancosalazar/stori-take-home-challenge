variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS tasks will run"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group for the ECS service"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener (for dependency)"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image to run in the ECS task"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "task_cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for the task in MB (512, 1024, 2048, etc.)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 10
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
