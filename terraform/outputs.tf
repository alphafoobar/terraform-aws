output "ecs_name" {
  value = aws_ecs_cluster.kaizen-ecs.name
}

output "public_lb_dns" {
  value = aws_lb.public-lb.dns_name
}

output "public_lb_name" {
  value = aws_lb.public-lb.name
}

output "lb_security_group" {
  value = aws_security_group.allow-lb-traffic
}

output "public_lb_listener" {
  value = aws_lb_listener.public-lb-listener
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc" {
  value = module.vpc.vpc
}

# Variables below here are just here until the resources are migrated to terraform.
# The variables are just directly output so services can deploy.
output "vpc_id" {
  sensitive = true
  value     = module.vpc.vpc.id
}

output "deployment_role_arn" {
  value = aws_iam_role.deployment_role.arn
}
