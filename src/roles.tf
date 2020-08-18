resource "aws_iam_role_policy" "ecsTaskExecutionRoleReadSecrets" {
  name = "ecsTaskExecutionRoleReadSecrets"
  role = aws_iam_role.ecsTaskExecutionRole.id

  policy = <<-EOF
  {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:GetResourcePolicy",
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:ListSecretVersionIds"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": "secretsmanager:GetRandomPassword",
                "Resource": "*"
            }
        ]
    }
  EOF
}
resource "aws_iam_role_policy" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  role = aws_iam_role.ecsTaskExecutionRole.id

  policy = <<-EOF
  {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "ec2:*"
                ],
                "Resource": "*"
            }
        ]
    }
  EOF
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
      
    }
  ]
}
EOF
  tags = {
    tag-key = "tag-value"
  }
}