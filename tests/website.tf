module "website" {
  source = "../"

  stage = "stage"

  website = {
    source_dir = "./"
  }
}
