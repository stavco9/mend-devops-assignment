output "dns_zone_name" {
  value = aws_route53_zone.mend_devops.name
}

output "dns_zone_id" {
  value = aws_route53_zone.mend_devops.zone_id
}