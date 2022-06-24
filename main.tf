/**
 * ## Usage
 *
 * Creates an IAM role for use as an EventBridge service role.
 *
 * ```hcl
 * module "eventbridge_iam_role" {
 *   source = "dod-iac/eventbridge-iam-role/aws"
 *
 *   name                         = format("app-%s-eventbridge-iam-role-%s", var.application, var.environment)
 *   codepipeline_pipelines_start = ["*"]
 *   tags                         = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = var.name
  assume_role_policy = length(var.assume_role_policy) > 0 ? var.assume_role_policy : data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "main" {
  dynamic "statement" {
    for_each = length(var.codepipeline_pipelines_start) > 0 ? [1] : []
    content {
      sid = "StartPipelineExecution"
      actions = [
        "codepipeline:StartPipelineExecution"
      ]
      effect    = "Allow"
      resources = contains(var.codepipeline_pipelines_start, "*") ? ["*"] : var.codepipeline_pipelines_start
    }
  }
}

resource "aws_iam_policy" "main" {
  count = length(var.codepipeline_pipelines_start) > 0 ? 1 : 0

  name        = length(var.policy_name) > 0 ? var.policy_name : format("%s-policy", var.name)
  description = length(var.policy_description) > 0 ? var.policy_description : format("The policy for %s.", var.name)
  policy      = data.aws_iam_policy_document.main.json
}

resource "aws_iam_role_policy_attachment" "main" {
  count = length(var.codepipeline_pipelines_start) > 0 ? 1 : 0

  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.0.arn
}
