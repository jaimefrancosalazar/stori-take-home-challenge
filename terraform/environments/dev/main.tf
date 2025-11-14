# Stori Take-Home Challenge - Dev Environment
# This configuration creates a complete ECS infrastructure with auto-scaling and monitoring

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Terraform Cloud configuration
  cloud {
    organization = "jaimefrancosalazar"

    workspaces {
      name = "stori-challenge-dev"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = "Jaime Franco"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway

  tags = {
    Environment = "dev"
  }
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  repository_name      = "${var.project_name}-app"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  max_image_count      = 10
  untagged_image_days  = 7

  tags = {
    Environment = "dev"
  }
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  container_port             = var.container_port
  health_check_path          = var.health_check_path
  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Environment = "dev"
  }
}

# ECS Module
module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  alb_listener_arn      = module.alb.listener_arn
  container_name        = var.container_name
  container_image       = var.container_image
  container_port        = var.container_port
  health_check_path     = var.health_check_path
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  min_capacity          = var.min_capacity
  max_capacity          = var.max_capacity
  environment_variables = var.environment_variables
  log_retention_days    = var.log_retention_days
  aws_region            = var.aws_region

  tags = {
    Environment = "dev"
  }

  depends_on = [module.alb]
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_name            = var.project_name
  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  alb_arn_suffix          = module.alb.alb_arn_suffix
  log_group_name          = module.ecs.log_group_name
  alert_email             = var.alert_email

  tags = {
    Environment = "dev"
  }

  depends_on = [module.ecs]
}
