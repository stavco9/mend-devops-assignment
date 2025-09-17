module "networking" {
  source = "../../../../../../modules/aws/networking"

  vpc_cidr = "10.0.6.0/23"

  project         = "mend-devops"
  owner           = "stavco9@gmail.com"
  environment     = "dev"
  private_subnets = ["10.0.6.0/26", "10.0.6.64/26", "10.0.6.128/26"]
  public_subnets  = ["10.0.7.0/26", "10.0.7.64/26", "10.0.7.128/26"]

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_s3_endpoint = true
}