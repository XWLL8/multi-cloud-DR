output "alb_sg" {
  value = aws_security_group.alb_sg.id

}
output "alb_arn" {
  value = aws_lb.gallery_web_alb.arn
}
output "alb_target_group_arn" {
  value = aws_lb_target_group.gallery_web_tg.arn
}
output "alb_dns_name" {
  value = aws_lb.gallery_web_alb.dns_name
}
output "alb_zone_id" {
  value = aws_lb.gallery_web_alb.zone_id
}