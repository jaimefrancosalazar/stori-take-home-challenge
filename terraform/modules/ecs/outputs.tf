output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_id" {
  description = "ECS Service ID"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.main.arn
}

output "task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "IAM role ARN for ECS task"
  value       = aws_iam_role.ecs_task.arn
}

output "security_group_id" {
  description = "Security Group ID for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "scale_out_alarm_arn" {
  description = "CloudWatch Alarm ARN for scale out (CPU high)"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "scale_in_alarm_arn" {
  description = "CloudWatch Alarm ARN for scale in (CPU low)"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}
