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
