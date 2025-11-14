output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.main.arn
}

output "target_group_name" {
  description = "Target Group name"
  value       = aws_lb_target_group.main.name
}

output "alb_security_group_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb.id
}

output "listener_arn" {
  description = "ALB Listener ARN"
  value       = aws_lb_listener.http.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target Group ARN suffix for CloudWatch metrics"
  value       = aws_lb_target_group.main.arn_suffix
}
