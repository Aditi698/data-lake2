resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "ec2_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.data-lake-498.arn,
          "${aws_s3_bucket.data-lake-498.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "ec2_s3_access_profile"
  role = aws_iam_role.ec2_s3_access.name
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-05842291b9a0bd79f" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_access.name

  tags = {
    Name = "EC2-S3-Upload"
  }
}
