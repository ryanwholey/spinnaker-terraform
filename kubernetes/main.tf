data "aws_availability_zones" "available" {
  state = "available"
}

module "network" {
  source = "./modules/network"

  cidr   = "10.0.0.0/16"
  azs    = [for name in data.aws_availability_zones.available.names: name]
  prefix = var.cluster
}

