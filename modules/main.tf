terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Example: choose us-east-2 (Ohio)
provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}

module "s3_example" {
  source = "./modules/s3"

  providers = {
    aws = aws.ohio
  }

  bucket_base_name  = "myapp-assets"
  region            = "us-east-2" # appears in the name
  enable_versioning = true
  tags = {
    Environment = "dev"
    Owner       = "platform"
  }
}

output "bucket_name" {
  value = module.s3_example.bucket_name
}
