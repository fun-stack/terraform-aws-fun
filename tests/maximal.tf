module "maximal" {
  source = "../"

  stage = "stage"

  # domain = {
  #   name                = "example.com"
  #   deploy_to_subdomain = "something"
  #   catch_all_email     = "me@example.net"
  # }

  website = {
    source_dir              = "./src"
    cache_files_regex       = ".*-hashed.(js|css)"
    content_security_policy = "some-header"
    rewrites = {
      "robots.txt" = "robots.deny.txt"
    }
  }

  http = {
    extra_allow_origins = ["http://localhost:12345"] # cors of http api allows origin

    api = {
      source_dir  = "./src"
      handler     = "main.httpApi"
      runtime     = "nodejs18.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }

    rpc = {
      source_dir  = "./src"
      handler     = "main.httpRpc"
      runtime     = "nodejs18.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }
  }

  ws = {
    rpc = {
      source_dir  = "./src"
      handler     = "main.wsRpc"
      runtime     = "nodejs18.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }

    event_authorizer = {
      source_dir  = "./src"
      handler     = "main.wsEventAuth"
      runtime     = "nodejs18.x"
      memory_size = 256
      environment = {
        NODE_OPTIONS = "--enable-source-maps"
      }
    }
  }

  auth = {
    # image_base64_content  = "filebase64(auth.jpg)"
    # css_content           = "file(auth.css)"
    extra_redirect_urls = ["http://localhost:12345"] # auth can redirect to that website
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
