module "minimal" {
  source = "../"

  stage = "stage"

  providers = {
    aws = aws
    aws.us-east-1 = aws.us-east-1
  }
}
