terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "tf-state-20250511233244056000000001"
    key          = "vpc.tfstate"
    region       = "me-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "me-south-1"
  default_tags {
    tags = var.default_tags
  }
}
