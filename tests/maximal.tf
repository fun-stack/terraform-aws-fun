module "maximal" {
  source = "../"

  stage = "stage"

  # domain = {
  #   name                = "example.com"
  #   deploy_to_subdomain = "something"
  #   catch_all_email     = "me@example.net"
  # }

  website = {
    source_dir              = "./"
    cache_files_regex       = ".*-hashed.(js|css)"
    content_security_policy = "some-header"
    rewrites = {
      "robots.txt" = "robots.deny.txt"
    }
  }

  http = {
    api = {
      source_dir  = "./"
      handler     = "main.httpApi"
      runtime     = "nodejs14.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }

    rpc = {
      source_dir  = "./"
      handler     = "main.httpRpc"
      runtime     = "nodejs14.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }
  }

  ws = {
    rpc = {
      source_dir  = "./"
      handler     = "main.wsRpc"
      runtime     = "nodejs14.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }

    event_authorizer = {
      source_dir  = "./"
      handler     = "main.wsEventAuth"
      runtime     = "nodejs14.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }
  }

  auth = {
    # image_file = "auth.jpg"
    # css_file   = "auth.css"
  }

  dev_setup = {
    enabled           = true
    local_website_url = "http://localhost:12345" # auth can redirect to that website, cors of http api allows origin
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
