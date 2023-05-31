module "website" {
  source = "../"

  stage = "stage"

  website = {
    source_dir = "./src"
    environment = {
      "boo" = true
      "num" = 1
      "str" = "hello"
    }
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
