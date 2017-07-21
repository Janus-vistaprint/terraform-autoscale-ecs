
# determine service account for ELB, this is needed for policy below
data "aws_elb_service_account" "main" {}

# create log bucket, with glacier transition and 90 day expiration.
resource "aws_s3_bucket" "logs" {
  bucket = "${var.aws_log_bucket}"

  force_destroy = "${var.destroy_bucket_on_delete}"

  lifecycle_rule {
    id      = "${var.lb_name}-logrotate"
    prefix  = "/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.aws_log_bucket}/${var.lb_name}/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}



