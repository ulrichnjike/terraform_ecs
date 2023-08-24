resource "aws_s3_bucket" "artifacts_bucket" {
  bucket = "your-bucket-name" #choose your bucket name
  acl    = "private"
}