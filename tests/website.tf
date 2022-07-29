module "website" {
  source = "../"

  name_prefix = "stage"

  website = {
    source_dir = "./"
  }
}
