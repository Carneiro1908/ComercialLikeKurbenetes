# Creating role for CI/CD infrastructure using GitHub Actions
resource "aws_iam_role" "github_actions_infra_role" {
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

# Network and compute permissions for VPC, subnets, gateways, routing, security groups, and basic EC2 provisioning tasks.
resource "aws_iam_policy" "github_actions_networking_policy" {
  name        = "github-actions-networking-policy"
  description = "Permissions for VPC, networking, and EC2 provisioning tasks"

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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_networking_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_networking_policy.arn
}

# EKS cluster management permissions for creating and managing Kubernetes infrastructure.
resource "aws_iam_policy" "github_actions_eks_policy" {
  name        = "github-actions-eks-policy"
  description = "Permissions for EKS cluster and node group operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSPermissions"
        Effect   = "Allow"
        Resource = "*"
        Action   = ["eks:*"]
      },
      {
        Sid      = "EKSClusterRead"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_eks_policy.arn
}

# IAM and OIDC permissions for creating roles, policies, and GitHub/OIDC providers used by the infrastructure stack.
resource "aws_iam_policy" "github_actions_iam_policy" {
  name        = "github-actions-iam-policy"
  description = "Permissions for IAM role, policy, and OIDC provider management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
          "iam:GetRolePolicy",
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
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion"
        ]
      },
      {
        Sid      = "IAMRolesForIRSAAndGrafana"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:TagPolicy",
          "iam:PassRole"
        ]
      },
      {
        Sid      = "IAMOIDCProviderRead"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders",
          "iam:CreateOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider"
        ]
      },
      {
        Sid      = "ServiceLinkedRoles"
        Effect   = "Allow"
        Resource = "*"
        Action   = ["iam:CreateServiceLinkedRole"]
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "eks.amazonaws.com",
              "eks-nodegroup.amazonaws.com",
              "elasticloadbalancing.amazonaws.com",
              "autoscaling.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_iam_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_iam_policy.arn
}

# Terraform state backend and locking permissions for S3 and DynamoDB operations.
resource "aws_iam_policy" "github_actions_state_policy" {
  name        = "github-actions-state-policy"
  description = "Permissions for Terraform state storage and locking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateBackend"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketCORS",
          "s3:GetBucketLogging",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketTagging",
          "s3:GetBucketWebsite",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetAccelerateConfiguration"
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
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeKinesisStreamingDestination",
          "dynamodb:DescribeTableReplicaAutoScaling"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_state_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_state_policy.arn
}

# Container registry, logging, and encryption permissions for images, log groups, and KMS keys.
resource "aws_iam_policy" "github_actions_container_policy" {
  name        = "github-actions-container-policy"
  description = "Permissions for ECR, CloudWatch Logs, and KMS operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
          "ecr:SetRepositoryPolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability"
        ]
      },
      {
        Sid      = "ECRForceDelete"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ecr:ListImages",
          "ecr:BatchDeleteImage",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories"
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

resource "aws_iam_role_policy_attachment" "github_actions_container_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_container_policy.arn
}

# Monitoring and observability permissions for AMP, Alert Manager, and Grafana workspaces.
resource "aws_iam_policy" "github_actions_observability_policy" {
  name        = "github-actions-observability-policy"
  description = "Permissions for AMP and Grafana workspace management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AMPWorkspaceManagement"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "aps:CreateWorkspace",
          "aps:DescribeWorkspace",
          "aps:ListWorkspaces",
          "aps:UpdateWorkspaceAlias",
          "aps:DeleteWorkspace",
          "aps:TagResource",
          "aps:UntagResource",
          "aps:ListTagsForResource"
        ]
      },
      {
        Sid      = "AMPRulesAndAlerting"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "aps:CreateRuleGroupsNamespace",
          "aps:DescribeRuleGroupsNamespace",
          "aps:PutRuleGroupsNamespace",
          "aps:DeleteRuleGroupsNamespace",
          "aps:CreateAlertManagerDefinition",
          "aps:DescribeAlertManagerDefinition",
          "aps:PutAlertManagerDefinition",
          "aps:DeleteAlertManagerDefinition"
        ]
      },
      {
        Sid      = "GrafanaWorkspaceManagement"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "grafana:CreateWorkspace",
          "grafana:DescribeWorkspace",
          "grafana:UpdateWorkspace",
          "grafana:DeleteWorkspace",
          "grafana:ListWorkspaces",
          "grafana:TagResource",
          "grafana:UntagResource",
          "grafana:ListTagsForResource",
          "grafana:DescribeWorkspaceAuthentication",
          "grafana:UpdateWorkspaceAuthentication",
          "grafana:UpdatePermissions",
          "grafana:DescribePermissions"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_observability_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_observability_policy.arn
}

# Cleanup permissions for temporary network resources, load balancers, and identity center lookups.
resource "aws_iam_policy" "github_actions_cleanup_policy" {
  name        = "github-actions-cleanup-policy"
  description = "Permissions for cleanup activities after infrastructure teardown"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "IdentityCenterUserLookup"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "sso:ListInstances",
          "sso:DescribeInstance",
          "identitystore:GetUserId",
          "identitystore:DescribeUser",
          "identitystore:ListUsers"
        ]
      },
      {
        Sid      = "ENIAndEIPCleanup"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:DescribeAddresses",
          "ec2:DisassociateAddress",
          "ec2:ReleaseAddress"
        ]
      },
      {
        Sid      = "LoadBalancerCleanup"
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DeleteListener"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_cleanup_attachment" {
  role       = aws_iam_role.github_actions_infra_role.name
  policy_arn = aws_iam_policy.github_actions_cleanup_policy.arn
}

# ARN Output to use on the role 
output "github_actions_infra_role_arn" {
  value       = aws_iam_role.github_actions_infra_role.arn
  description = "ARN of the IAM role for GitHub Actions to assume"
}