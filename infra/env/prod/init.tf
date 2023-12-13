terraform {
  required_version = "1.3.4"
  backend "local" {
    path = "./prod.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {}
  }
}