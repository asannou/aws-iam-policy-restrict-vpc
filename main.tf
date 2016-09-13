provider "aws" {
  region = "${var.aws_region}"
}

data "aws_caller_identity" "aws" {}

resource "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"
  vars {
    name = "${var.name}"
    region = "${var.aws_region}"
    account_id = "${data.aws_caller_identity.aws.account_id}"
    vpc_id = "${var.vpc_id}"
  }
}

resource "aws_iam_policy" "policy" {
  name = "${var.name}"
  policy = "${template_file.policy.rendered}"
}

resource "aws_iam_role" "role" {
  name = "${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}"
  roles = ["${aws_iam_role.role.name}"]
}

