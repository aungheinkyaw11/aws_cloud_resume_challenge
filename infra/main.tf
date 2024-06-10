resource "aws_s3_bucket" "aws-cloud-resume-challenge-ahk" {
  bucket = "aws-cloud-resume-challenge-ahk"
    tags = {
      Name        = "project"
      Environment = "cloud resume challenge"
    }
}