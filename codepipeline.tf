resource "aws_codepipeline" "web_app_pipeline" {
  name     = "web-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "yourusername"
        Repo       = "your-repo"
        Branch     = "master"
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.web_app_build.name
      }
    }
  }
}