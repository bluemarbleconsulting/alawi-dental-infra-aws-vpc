terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "tf-state-20260329231040326100000001"
    key          = "vpc.tfstate"
    region       = "eu-central-2"
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

provider "aws" {
  alias  = "zurich"
  region = "eu-central-2"
  default_tags {
    tags = var.default_tags
  }
}
