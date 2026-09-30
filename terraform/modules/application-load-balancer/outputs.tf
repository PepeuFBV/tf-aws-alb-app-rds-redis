output "dns_name" {
  value = aws_lb.application.dns_name
}

output "arn" {
  value = aws_lb.application.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.application.arn
}
