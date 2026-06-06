data "aws_iam_policy_document" "ec2_service_policy"{
    statement {
        sid = "1"
        effect = "Allow"
        actions = [
            "ec2:Describe*",
            "ec2:GetConsole*",
            "ec2:RunInstances"
        ]
        resources = ["*"]
    }
}

data "aws_partition" "aws_p"{}

data "aws_iam_policy_document" "budget_execution_role" {
    statement {
        sid = "1"
        effect = "Allow"
        principals {
            type= "Service"
            identifiers = ["budgets.${data.aws_partition.aws_p.dns_suffix}"]
        }
        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "deny_ec2_run"{
    statement {
      sid = "1"
      effect = "Deny"
      actions = [
        "ec2:RunInstances"
      ]
      resources = ["*"]
    }
}

resource "aws_iam_policy" "service_policy" {
  name = "EC2ServicePolicy"
  policy = data.aws_iam_policy_document.ec2_service_policy.json
}

resource "aws_iam_role" "execution_role"{
    name = "Budget_Execution_Role"
    assume_role_policy = data.aws_iam_policy_document.budget_execution_role.json
}

resource "aws_iam_policy" "deny_ec2_run_policy"{
    name = "Deny_EC2_run"
    policy = data.aws_iam_policy_document.deny_ec2_run.json
}

resource "aws_budgets_budget" "ec2"{
    name = "budget-ec2-monthly"
    budget_type = "COST"
    limit_amount = "5"
    limit_unit = "USD"
    time_period_end   = "2087-06-15_00:00"
    time_period_start = "2026-07-01_00:00"
    time_unit         = "MONTHLY"
    
    cost_filter {
        name = "Service"
        values = [
            "Amazon Elastic Compute Cloud - Compute",
        ]
    }
    notification {
   comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
   subscriber_email_addresses = [var.email]
  }
}

resource "aws_budgets_budget_action" "deny_ec2"{
    budget_name = aws_budgets_budget.ec2.name
    action_type = "APPLY_IAM_POLICY"
    approval_model = "AUTOMATIC"
    notification_type = "FORECASTED"
    execution_role_arn = aws_iam_role.execution_role.arn

    action_threshold {
      action_threshold_type = "PERCENTAGE"
      action_threshold_value = 80
    }
    definition {
      iam_action_definition {
        policy_arn = aws_iam_policy.deny_ec2_run_policy.arn
        roles = ["aws_iam_policy.service_policy.name"]
      }
    }

    subscriber {
      address = var.email
      subscription_type = "EMAIL"
    }

}

# setup aws budget
resource "aws_budgets_budget" "a_dollar_budget"{
    name = "1 dollar spend"
    budget_type = "COST"
    limit_amount = "1"
    limit_unit = "USD"
    time_period_start = "2026-05-29_00:00"
    time_period_end =   "2030-01-01_00:00"
    time_unit = "MONTHLY"    
}

