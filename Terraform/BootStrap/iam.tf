# Creating role for CI/CD infrastructure using GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-infra-role"

  # Trust Policy: Defines WHO can assume this role (GitHub OIDC)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Carneiro1908/ComercialKurbenetes:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_role.name # Coloque o nome da sua variável da role aqui
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Inline Policy: Defines exact AWS permissions for the GitHub Actions pipeline
resource "aws_iam_role_policy" "github_actions_permissions" {
  name = "github-actions-permissions-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "NetworkingAndVPCPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ec2:*Vpc*",
          "ec2:*Subnet*",
          "ec2:*Gateway*",
          "ec2:*Route*",
          "ec2:*Address*",
          "ec2:*SecurityGroup*",
          "ec2:*NetworkAcl*",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:Describe*"
        ]
      },
      {
        Sid      = "EC2AndLaunchTemplates"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateKeyPair",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress"
        ]
      },
      {
        Sid      = "EKSPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "eks:*"
        ]
      },
      {
        Sid      = "IAMFullControlForEKSAndOIDC"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PassRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:ListPolicyVersions",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateOpenIDConnectProvider", # Added: Required for EKS Service Accounts (IRSA)
          "iam:DeleteOpenIDConnectProvider", # Added: Required for OIDC provider teardown
          "iam:GetOpenIDConnectProvider",    # Added: Required to verify OIDC status
          "iam:TagOpenIDConnectProvider"     # Added: Required to track OIDC resources
        ]
      },
      {
        Sid    = "S3StateBackend"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::comercial-k8s-protected-storage-tomas-2026",
          "arn:aws:s3:::comercial-k8s-protected-storage-tomas-2026/*"
        ]
      },
      {
        Sid      = "DynamoDBLocking"
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:eu-north-1:*:table/comercial-k8s-terraform-locks"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
      },
      {
        Sid      = "ECRManagement"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:ListTagsForResource",
          "ecr:SetRepositoryPolicy",       # Added: Required if managing container access policies
          "ecr:GetRepositoryPolicy"        # Added: Required to inspect repository access
        ]
      },
      {
        Sid      = "CloudWatchLogsManagement"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "logs:CreateLogGroup",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:TagResource",
          "logs:PutRetentionPolicy"
        ]
      },
      {
        Sid      = "KMSKeyManagement"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "kms:CreateKey",
          "kms:TagResource",
          "kms:DescribeKey",
          "kms:ScheduleKeyDeletion",
          "kms:CreateAlias",
          "kms:DeleteAlias",               
          "kms:RetireGrant",
          "kms:CreateGrant",               
          "kms:ListGrants",              
          "kms:ListAliases"
        ]
      }
    ]
  })
}

# ARN Output to use on the role 
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "ARN of the IAM role for GitHub Actions to assume"
}