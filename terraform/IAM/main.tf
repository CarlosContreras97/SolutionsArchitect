resource "aws_iam_user" "userAdmin" {
    name = "CarlosLabAdmin"
}

resource "aws_iam_group" "AdminGroup" {
    name = "Admin"    
}

resource "aws_iam_user_group_membership" "membership"{
    user = aws_iam_user.userAdmin.name
    groups = [aws_iam_group.AdminGroup.name]
}

resource "aws_iam_user_policy" "IAMList"{
    name = "IAMList"
    user = aws_iam_user.userAdmin.name
    policy = jsonencode(
        {
            "Version":"2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "iam:ListUsers",
                        "iam:GetUser"
                    ],
                    "Resource": "*"
                }
            ]
        }
    )
}

resource "aws_iam_group_policy" "admin_policy" {
    name = "admin"
    group = aws_iam_group.AdminGroup.name
    policy = jsonencode(
        {
            "Version":"2012-10-17",
            "Statement": [
                {
                    "Sid": "allowAdminAccess",
                    "Effect": "Allow",
                    "Action": "*",
                    "Resource": "*"
                }                
            ]
        }
    )
}

# data source for assuming role policy

data "aws_iam_policy_document" "admin_policy_non_specific"{
    statement {
      effect = "Allow"
      actions =["*"]
      resources = ["*"]
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

