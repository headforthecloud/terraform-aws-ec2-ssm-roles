data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# data "aws_ami" "amazon-linux-2023" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023.0.20230419.0-kernel-6.1-x86_64"]
#   }
# }