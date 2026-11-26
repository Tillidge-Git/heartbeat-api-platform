resource "aws_iam_policy" "iam_boundary" {
  #checkov:skip=CKV_AWS_355:Session Manager actions mirror AmazonSSMManagedInstanceCore and can't be resource-scoped; boundary is a ceiling, not a grant; to be narrowed from CloudTrail.
  #checkov:skip=CKV_AWS_290:Session Manager actions mirror AmazonSSMManagedInstanceCore and can't be resource-scoped; boundary is a ceiling, not a grant; to be narrowed from CloudTrail.

  name = "iam-role-boundary-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "dynamodboundary"
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:Scan"]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/heartbeat*"
      },
      {
        Sid      = "ssmboundary"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/heartbeat/*"
      },
      {
        Sid      = "snsboundary"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:heartbeat*"
      },
      {
        Sid    = "logsboundary"
        Effect = "Allow"
        Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/heartbeat*:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/heartbeat*:*"
        ]
      },
      {
        Sid      = "S3packageboundary"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.app_package_bucket.arn}/*"
      },
      {
        Sid    = "SessionManagerBoundary"
        Effect = "Allow"
        Action = ["ssm:DescribeAssociation", "ssm:GetDeployablePatchSnapshotForInstance", "ssm:GetDocument", "ssm:DescribeDocument",
          "ssm:GetManifest", "ssm:ListAssociations", "ssm:ListInstanceAssociations", "ssm:PutInventory", "ssm:PutComplianceItems", "ssm:PutConfigurePackageResult", "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus", "ssm:UpdateInstanceInformation", "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel", "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage", "ec2messages:FailMessage", "ec2messages:GetEndpoint", "ec2messages:GetMessages", "ec2messages:SendReply"]
        Resource = "*"
      },
    ]
  })
}