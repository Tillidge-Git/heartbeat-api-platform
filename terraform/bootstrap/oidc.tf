data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_route53_zone" "main" {
  name = "tillidge-heartbeat.click"
}


resource "aws_iam_role" "oidc_plan_role" {
  name = "ci-heartbeat-oidc-plan-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:Tillidge-Git/heartbeat-api-platform:pull_request"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.oidc_plan_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "plan_state_access" {
  name = "ci-heartbeat-plan-state-access"
  role = aws_iam_role.oidc_plan_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListStateBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.state_bucket.arn
      },
      {
        Sid      = "ReadState"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.state_bucket.arn}/*"
      },
      {
        Sid      = "ManageLockFiles"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.state_bucket.arn}/*.tflock"
      }
    ]
  })
}

###################

resource "aws_iam_role" "oidc_apply_role" {
  name = "ci-heartbeat-oidc-apply-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:Tillidge-Git/heartbeat-api-platform:ref:refs/heads/main"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "apply_read_only" {
  role       = aws_iam_role.oidc_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "apply_state_access" {
  name = "ci-heartbeat-apply-state-access"
  role = aws_iam_role.oidc_apply_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListStateBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.state_bucket.arn
      },
      {
        Sid      = "Readwritestate"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.state_bucket.arn}/main/*"
      },

      {
        Sid      = "ManageLockFiles"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.state_bucket.arn}/main/*.tflock"
      }
    ]
  })
}

resource "aws_iam_role_policy" "apply_infra_access" {
  name = "ci-heartbeat-apply-infra-access"
  role = aws_iam_role.oidc_apply_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2InfraAccess"
        Effect   = "Allow"
        Action   = "ec2:*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid      = "ASGInfraAccess"
        Effect   = "Allow"
        Action   = "autoscaling:*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid      = "ALBInfraAccess"
        Effect   = "Allow"
        Action   = "elasticloadbalancing:*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid    = "DynamoDBInfraAccess"
        Effect = "Allow"
        Action = ["dynamodb:CreateTable", "dynamodb:DeleteTable",
          "dynamodb:UpdateTable", "dynamodb:UpdateContinuousBackups",
        "dynamodb:TagResource", "dynamodb:UntagResource"]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/heartbeat*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid    = "IAMInfraAccess"
        Effect = "Allow"
        Action = ["iam:DeleteRole", "iam:UpdateAssumeRolePolicy", "iam:TagRole", "iam:UntagRole",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile", "iam:TagInstanceProfile"]
        Resource = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/heartbeat*",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/heartbeat*"]
      },
      {
        Sid    = "IAMboundarycondition"
        Effect = "Allow"
        Action = ["iam:CreateRole", "iam:PutRolePolicy",
        "iam:DeleteRolePolicy", "iam:AttachRolePolicy", "iam:DetachRolePolicy"]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/heartbeat*"
        Condition = {
          StringEquals = {
            "iam:PermissionsBoundary" = aws_iam_policy.iam_boundary.arn
          }
        }

      },
      {
        Sid      = "IAMpassroleInfraAccess"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/heartbeat*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
          }
        }

      },
      {
        Sid      = "IAMserviceroleInfraAccess"
        Effect   = "Allow"
        Action   = ["iam:CreateServiceLinkedRole"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = ["autoscaling.amazonaws.com", "elasticloadbalancing.amazonaws.com"]
          }
        }
      },
      {
        Sid      = "CloudWatchInfraAccess"
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:TagResource", "cloudwatch:UntagResource"]
        Resource = "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm:heartbeat*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid    = "CloudWatchLogsInfraAccess"
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:PutRetentionPolicy",
          "logs:DeleteRetentionPolicy", "logs:TagResource", "logs:UntagResource",
        "logs:PutMetricFilter", "logs:DeleteMetricFilter"]
        Resource = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/heartbeat*",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/heartbeat*"]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid    = "SNSInfraAccess"
        Effect = "Allow"
        Action = ["sns:CreateTopic", "sns:DeleteTopic", "sns:Subscribe",
        "sns:Unsubscribe", "sns:TagResource", "sns:UntagResource", "sns:SetTopicAttributes"]
        Resource = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:heartbeat*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "eu-west-2"
          }
        }
      },
      {
        Sid      = "Route53InfraAccess"
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/${data.aws_route53_zone.main.zone_id}"
      },
      {
        Sid    = "SSMInfraAccess"
        Effect = "Allow"
        Action = ["ssm:PutParameter", "ssm:DeleteParameter",
        "ssm:AddTagsToResource", "ssm:RemoveTagsFromResource"]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/heartbeat/*"
      },
      {
        Sid    = "LambdaInfraAccess"
        Effect = "Allow"
        Action = ["lambda:CreateFunction", "lambda:DeleteFunction", "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration", "lambda:TagResource", "lambda:UntagResource",
        "lambda:AddPermission", "lambda:RemovePermission"]
        Resource = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:heartbeat*"
      },
      {
        Sid    = "EventBridgeInfraAccess"
        Effect = "Allow"
        Action = ["events:PutTargets", "events:RemoveTargets", "events:PutRule",
        "events:TagResource", "events:UntagResource", "events:DeleteRule", "events:EnableRule", "events:DisableRule"]
        Resource = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/heartbeat*"
      }
    ]
  })
}
