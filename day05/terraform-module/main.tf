module "web_server" {
  source = "./ec2"

  ami_id         = "ami-0f58b397bc5c1f2e8"
  instance_type  = "t3.micro"
  instance_name  = "TerraWeek-EC2"
}
