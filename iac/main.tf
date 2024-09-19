# S3 BUCKET FOR PARSING DATA
resource "aws_s3_bucket" "s3-marko" {
  bucket = "s3-api-data-marko"

}
# S3 POLICY
resource "aws_s3_bucket_policy" "allow_access-marko" {
  bucket = aws_s3_bucket.s3-marko.id
  policy = data.aws_iam_policy_document.allow_access-marko.json
}
# S3 POLICY DOCUMENT
data "aws_iam_policy_document" "allow_access-marko" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::381492201388:user/mg-admin"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.s3-marko.arn,
      "${aws_s3_bucket.s3-marko.arn}/*",
    ]
  }
}

# ECR FOR STORING DOCKER IMAGES AND POLICY FOR IAM
resource "aws_ecr_repository" "ECR-marko" {
  name                 = "ecr-docker-marko"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "ecr-policy-marko" {
  repository = aws_ecr_repository.ECR-marko.name
  policy     = data.aws_iam_policy_document.policy-document-marko.json
}

data "aws_iam_policy_document" "policy-document-marko" {
  statement {
    sid    = "new policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::381492201388:user/mg-admin"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}


# DYNAMODB FOR STORING API RESPONSES
resource "aws_dynamodb_table" "dynamodb-marko" {
  name           = "dynamodb-marko"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Artist"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"


  attribute {
    name = "Artist"
    type = "S"
  }
}

# SNS MAIL TOPIC
resource "aws_sns_topic" "user_updates-marko" {
  name = "user-updates-topic-marko"
}





