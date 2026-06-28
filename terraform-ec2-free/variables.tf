variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Free tier eligible EC2 instance type"
  type        = string
  default     = "t2.micro" 
}
