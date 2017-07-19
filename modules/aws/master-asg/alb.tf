resource "aws_alb" "console" {
  name            = "${var.custom_dns_name == "" ? var.cluster_name : var.custom_dns_name}-con"
  internal        = "${var.public_vpc ? false : true}"
  security_groups = ["${var.console_sg_ids}"]
  subnets         = ["${var.subnet_ids}"]

  idle_timeout = 3600

  tags = "${merge(map(
      "Name", "${var.cluster_name}-api-external",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "tectonicClusterID", "${var.cluster_id}"
    ), var.extra_tags)}"
}

resource "aws_alb_target_group" "tectonic_console_http" {
  port     = 32001
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_target_group" "tectonic_console_https" {
  port     = 32000
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_listener" "tectonic_console_https" {
  load_balancer_arn = "${aws_alb.console.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.alb_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tectonic_console_https.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "tectonic_console_http" {
  load_balancer_arn = "${aws_alb.console.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tectonic_console_http.arn}"
    type             = "forward"
  }
}


resource "aws_autoscaling_attachment" "tectonic_console_attachment_http" {
  autoscaling_group_name = "${aws_autoscaling_group.masters.id}"
  alb_target_group_arn   = "${aws_alb_target_group.tectonic_console_http.arn}"
}

resource "aws_autoscaling_attachment" "tectonic_console_attachment_https" {
  autoscaling_group_name = "${aws_autoscaling_group.masters.id}"
  alb_target_group_arn   = "${aws_alb_target_group.tectonic_console_https.arn}"
}


resource "aws_route53_record" "ingress-public" {
  count   = "${var.public_vpc}"
  zone_id = "${var.external_zone_id}"
  name    = "${var.custom_dns_name == "" ? var.cluster_name : var.custom_dns_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.console.dns_name}"
    zone_id                = "${aws_alb.console.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ingress-private" {
  zone_id = "${var.internal_zone_id}"
  name    = "${var.custom_dns_name == "" ? var.cluster_name : var.custom_dns_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.console.dns_name}"
    zone_id                = "${aws_alb.console.zone_id}"
    evaluate_target_health = true
  }
}