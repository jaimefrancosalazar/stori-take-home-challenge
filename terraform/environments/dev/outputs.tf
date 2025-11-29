output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for ECS tasks"
  value       = module.ecs.log_group_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL for Docker images"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR Repository name"
  value       = module.ecr.repository_name
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    region              = var.aws_region
    environment         = "dev"
    project_name        = var.project_name
    alb_url             = "http://${module.alb.alb_dns_name}"
    ecs_cluster         = module.ecs.cluster_name
    ecs_service         = module.ecs.service_name
    min_capacity        = var.min_capacity
    max_capacity        = var.max_capacity
    scale_out_threshold = "60%"
    scale_in_threshold  = "20%"
    alert_threshold     = "80%"
  }
}
