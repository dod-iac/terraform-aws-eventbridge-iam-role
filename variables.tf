variable "assume_role_policy" {
  type        = string
  description = "The assume role policy for the AWS IAM role.  If blank, allows EventBridge to assume the role."
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the AWS IAM role."
}

variable "policy_description" {
  type        = string
  description = "The description of the AWS IAM policy. Defaults to \"The policy for [NAME]\"."
  default     = ""
}

variable "policy_name" {
  type        = string
  description = "The name of the AWS IAM policy.  Defaults to \"[NAME]-policy\"."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AWS IAM role."
  default     = {}
}

variable "codepipeline_pipelines_start" {
  type        = list(string)
  description = "The ARNs of the AWS CodePipeline pipelines that this role can start.  Use [\"*\"] to allow all pipelines."
  default     = []
}
