# create DNS record for our LB in Route53
resource "aws_route53_record" "www" {
  count   = "${var.route53_dns_name == "" ? 0 : 1}"
  zone_id = "${var.route53_dns_zone_id}"
  name    = "${var.route53_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.main.dns_name}"
    zone_id                = "${aws_alb.main.zone_id}"
    evaluate_target_health = true
  }
}
