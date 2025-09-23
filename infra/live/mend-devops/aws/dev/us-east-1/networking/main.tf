module "networking" {
  source = "../../../../../../modules/aws/networking"

  vpc_cidr = "10.0.8.0/23"

  project         = "mend-devops"
  owner           = "stavco9@gmail.com"
  environment     = "dev"
  private_subnets = ["10.0.8.0/26", "10.0.8.64/26", "10.0.8.128/26"]
  public_subnets  = ["10.0.9.0/26", "10.0.9.64/26", "10.0.9.128/26"]

  single_nat_gateway = true
  enable_nat_gateway = true
  enable_s3_endpoint = true
}