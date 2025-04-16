variable "cluster_name" {
  default = "prasad-eks"
}

variable "vpc_id" {
  default = "vpc-059591b76b17a4457"
}

variable "subnet_ids" {
  default = [
    "subnet-0956f23813c3f55b9",  # ap-south-1a
    "subnet-028125de1c2117bb0",  # ap-south-1b
    "subnet-017773966ffbc4fc4"   # ap-south-1c
  ]
}
