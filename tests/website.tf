module "website" {
  source = "../"

  stage = "stage"

  website = {
    source_dir = "./src"
    environment = {
      "foo" = true
      "obj" = {
        "nested" = 1
        "str" = "hello"
  }
    }
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
