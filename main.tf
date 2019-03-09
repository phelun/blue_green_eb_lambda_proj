provider "aws" {
  region = "eu-west-1"
}

variable "max_availability_zones" {
  default = "2"
}

#variable "zone_id" {
#  type        = "string"
#  description = "Route53 Zone ID"
#}

data "aws_availability_zones" "available" {}

############# External Modules: Networking #################

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "fmbah"
  stage      = "dev"
  name       = "test"
  cidr_block = "10.227.120.0/24"
}

module "subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  availability_zones = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  namespace          = "fmbah"
  stage              = "dev"
  name               = "test"
  region             = "eu-west-1"

  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

############# External Modules: EB Configurations #################

module "elastic_beanstalk_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=master"
  namespace   = "fmbah"
  stage       = "dev"
  name        = "app"
  description = "APP: elastic_beanstalk_application"
}

module "elastic_beanstalk_environment" {
  source    = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=master"
  namespace = "fmbah"
  stage     = "dev"
  name      = "env"

  #zone_id   = "${var.zone_id}"
  app = "${module.elastic_beanstalk_application.app_name}"

  instance_type           = "t2.small"
  autoscale_min           = 1
  autoscale_max           = 2
  updating_min_in_service = 0
  updating_max_batch      = 1

  loadbalancer_type   = "application"
  vpc_id              = "${module.vpc.vpc_id}"
  public_subnets      = "${module.subnets.public_subnet_ids}"
  private_subnets     = "${module.subnets.private_subnet_ids}"
  security_groups     = ["${module.vpc.vpc_default_security_group_id}"]
  #solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.9 running Docker 18.06.1-ce"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.8.1 running Python 3.6"
  keypair             = "aws-eb"

  env_vars = "${
      map(
        "ENV1", "Test1",
        "ENV2", "Test2",
        "ENV3", "Test3"
      )
    }"
}
