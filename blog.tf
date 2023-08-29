# Setup an IAM role with S3 access only, and add instance profile
resource "aws_iam_role" "standard_ec2_role" {
  name_prefix = "ssm_demo_ec2_role_with_no_ssm"
  description = "ssm_demo_ec2_role_with_no_ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ec2.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "ssm_s3_access_policy"
  path        = "/"
  description = "List S3 buckets and objects"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Effect = "Allow"
        Sid    = "S3Listing"
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.standard_ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_role_profile" {
  name_prefix = "ssm_demo_s3_instance_profile"
  role        = aws_iam_role.standard_ec2_role.name
}


# Setup an IAM role with S3 and SSM access, and add instance profile
resource "aws_iam_role" "ssm_ec2_role" {
  name_prefix = "ssm_demo_ec2_role_with_ssm"
  description = "ssm_demo_ec2_role_with_ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ec2.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_s3_policy" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ec2_ssm_role_profile" {
  name_prefix = "ssm_demo_ssm_and_s3_instance_profile"
  role        = aws_iam_role.ssm_ec2_role.name
}

# Create an EC2 security group, allowing global outgoing access
resource "aws_security_group" "ec2_security_group" {
  name_prefix = "ec2_ssm_test_sg"
  description = "Security Group for building ec2s to test SSM roles"

  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ec2_outgoing" {
  security_group_id = aws_security_group.ec2_security_group.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}

data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230419.0-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                  = data.aws_ami.amazon-linux-2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_role_profile.name

  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  subnet_id                   = aws_subnet.private_subnet.id

  user_data = <<-EOF
      #! /bin/bash
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl restart amazon-ssm-agent
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "ssm_demo_ec2_instance_with_std_profile"
  }
}

resource "aws_instance" "ec2_instance_with_ssm" {
  ami                  = data.aws_ami.amazon-linux-2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_role_profile.name

  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  subnet_id                   = aws_subnet.private_subnet.id

  user_data = <<-EOF
      #! /bin/bash
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl restart amazon-ssm-agent
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "ssm_demo_ec2_instance_with_ssm_profile"
  }
}

resource "aws_instance" "ec2_instance_no_profile" {
  ami                  = data.aws_ami.amazon-linux-2023.id
  instance_type        = var.instance_type

  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  subnet_id                   = aws_subnet.private_subnet.id

  user_data = <<-EOF
      #! /bin/bash
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl restart amazon-ssm-agent
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "ssm_demo_ec2_instance_with_no_profile"
  }
}

resource "aws_iam_role" "ssm_dhmc_role" {
  name_prefix = "ssm_dhmc_role"
  description = "IAM Role allowing dhmc access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ssm.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_dhmc_policy" {
  role       = aws_iam_role.ssm_dhmc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_ssm_service_setting" "test_setting" {
  setting_id    = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = aws_iam_role.ssm_dhmc_role.name
}


