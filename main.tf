terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.28.0"
    }
  }

  required_version = "~> 1.2.8"

  backend "s3" {
    bucket = "terraform-public-private-ec2-tfstate"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# ---------------------------------------------------------------------
# Resources

module "vpc" {
  source = "./modules/vpc"
  region = "ap-northeast-1"

  private_vpc_cidr      = "10.0.0.0/16"
  public_subnet_a_cidr  = "10.0.1.0/24"
  public_subnet_c_cidr  = "10.0.2.0/24"
  private_subnet_a_cidr = "10.0.3.0/24"
  private_subnet_c_cidr = "10.0.4.0/24"
}

module "ec2" {
  source              = "./modules/ec2"
  vpc_main_id         = module.vpc.vpc_main_id
  public_subnet_a_id  = module.vpc.public_subnet_a_id
  public_subnet_c_id  = module.vpc.public_subnet_c_id
  private_subnet_a_id = module.vpc.private_subnet_a_id
  private_subnet_c_id = module.vpc.private_subnet_c_id
  nat_gateway_a       = module.vpc.nat_gateway_a
}
