# Creating role for CI/CD using GitHub Actions
resource "aws_iam_role" "github_actions_cicd_role" {
  name = "github-actions-cicd-role"

  # Trust Policy: Defines WHO can assume this role (GitHub OIDC)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::547320736290:oidc-provider/token.actions.githubusercontent.com"
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

# Policies for the role to allow pushing/pulling Docker images to/from ECR and describing the EKS cluster

resource "aws_iam_policy" "ecr_push_pull" {
  name        = "github-actions-ecr-push-pull"
  description = "Allows pushing and pulling Docker images to/from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages"
        ]
        Resource = "arn:aws:ecr:eu-north-1:547320736290:repository/comercial-k8s-apps"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_describe_access" {
  name        = "github-actions-eks-describe"
  description = "Allows updating kubeconfig and describing the EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "arn:aws:eks:eu-north-1:547320736290:cluster/comercial-k8s-eks-cluster"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_push_pull" {
  role       = aws_iam_role.github_actions_cicd_role.name
  policy_arn = aws_iam_policy.ecr_push_pull.arn
}

resource "aws_iam_role_policy_attachment" "attach_eks_describe_access" {
  role       = aws_iam_role.github_actions_cicd_role.name
  policy_arn = aws_iam_policy.eks_describe_access.arn
}


# ARN Output to use on the role 
output "github_actions_cicd_role_arn" {
  value       = aws_iam_role.github_actions_cicd_role.arn
  description = "ARN of the IAM role for GitHub Actions to assume"
}