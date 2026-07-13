variable "filename" {
  description = "The path/name of the file to be created"
  type        = string
  default     = "/home/hp/TerraWeekTWS/day02/example.txt"
}

variable "content" {
  description = "The content to write inside the file"
  type        = string
  default     = "Hello, this file was created using Terraform!"
}
