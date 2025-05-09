resource "aws_route53_zone" "zozz_xyz" {
  name = "samplesite.xyz"
}

  resource "aws_route53_record" "virginia_record" {
  zone_id = aws_route53_zone.zozz_xyz.zone_id
  name    = "www.samplesite.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb_virginia.dns_name
    zone_id                = aws_lb.app_lb_virginia.zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight        = 50
  }

  set_identifier = "virginia"
}

resource "aws_route53_record" "ohio_record" {
  zone_id = aws_route53_zone.zozz_xyz.zone_id
  name    = "www.samplesite.xyz"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb_ohio.dns_name
    zone_id                = aws_lb.app_lb_ohio.zone_id
    evaluate_target_health = true
  }

  weighted_routing_policy {
    weight        = 50
  }
  
  set_identifier = "ohio"

}
