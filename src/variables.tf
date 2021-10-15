variable "app_name" {
	type = string
}

variable "region" {
	type = string
}

# vpc

variable "vpc_id" {
	type = string
}

# asg

variable "instance_ami" {
	type = string
}

variable "instance_type" {
	type = string
	default = "t2.medium"
}
