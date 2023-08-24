resource "aws_codebuild_project" "web_app_build" {
  name          = "web-app-build"
  description   = "Builds the web application"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts_bucket.bucket
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/yourusername/your-repo.git"
    buildspec       = "buildspec.yml"
  }
}