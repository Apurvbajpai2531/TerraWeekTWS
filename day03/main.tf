resource "aws_instance" "terraweek_ec2" {

  ami           = var.ami_id
  instance_type = var.instance_type


  tags = {
    Name = "TerraWeek-Day3-EC2"
  }


  user_data = file("userdata.sh")


  lifecycle {

    create_before_destroy = true

    prevent_destroy = false

  }

}
