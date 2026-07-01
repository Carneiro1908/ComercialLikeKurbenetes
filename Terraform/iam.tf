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
        Resource = "arn:aws:eks:eu-north-1:547320736290:cluster/eks-commercial-study"
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


# EKS rules

# Create an access entry for the GitHub Actions role in the EKS cluster
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = "eks-commercial-study" 
  principal_arn = "arn:aws:iam::547320736290:role/github-actions-cicd-role"
  type          = "STANDARD"
}

# Associate the AmazonEKSClusterAdminPolicy with the GitHub Actions role for full admin access to the EKS cluster
resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = "eks-commercial-study"  
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::547320736290:role/github-actions-cicd-role"

  access_scope {
    type = "cluster"
  }
}

# AMP rules
data "aws_iam_policy_document" "amp_irsa_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn] 
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:prometheus:amp-ingest"]
    }
  }
}

resource "aws_iam_role" "amp_ingest" {
  name               = "amp-ingest-role"
  assume_role_policy = data.aws_iam_policy_document.amp_irsa_assume.json
}

resource "aws_iam_role_policy_attachment" "amp_ingest" {
  role       = aws_iam_role.amp_ingest.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}