variable "ecr_uri" {
  description = "ECR URI"
  type = string
}

variable "apprunner_name" {
  description = "Name of the AppRunner Service"
  type = string
}

variable "apprunner_role" {
  description = "IAM AppRunner Role"
  type = string
}

variable "policy_name" {
  description = "IAM Policy name"
  type = string
}


