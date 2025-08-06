
# Copilot Prompt Snippets for FeedbackHub-on-AWS

_Last updated: August 2025_

[Project README](../README.md) | [Roadmap](../docs/roadmap.md) | [Architecture](../docs/architecture.md)

## How to Use
Copy any prompt below into GitHub Copilot Chat, ChatGPT, or your preferred AI coding assistant to generate code, workflows, or documentation for this repo.


## Table of Contents
- [DevOps & Platform Engineer](#devops--platform-engineer)
- [Security Engineer](#security-engineer)
- [MLOps & AI Engineer](#mlops--ai-engineer)
- [Fullstack/Next.js Developer](#fullstacknextjs-developer)
- [Cloud Architect](#cloud-architect)
- [SRE/Observability Engineer](#sreobservability-engineer)
- [General/Meta](#generalmeta)

---

## DevOps & Platform Engineer
*Focus: Terraform, ECS, EKS, CI/CD, scaling, automation, observability.*


### Terraform & AWS Infra
```
"Write a Terraform module to create an AWS CloudFront distribution for ECS service ALB."
"Modify ECS Task Definition to mount EFS volume with correct access point and security group from `network` module."
"Create a reusable Terraform module for multi-region S3 bucket replication with KMS encryption and event notifications."
"Add a Terraform module to provision an AWS Lambda function with VPC access, IAM least privilege, and CloudWatch log group."
"Refactor Terraform modules to use `terraform_remote_state` for cross-module outputs (e.g., VPC, subnets, security groups)."
"Write a Terraform module to deploy an EKS cluster with managed node groups, OIDC provider, and IRSA for service accounts."
```


### GitHub Actions & CI/CD
```
"Update GitHub Actions deploy.yml to trigger Blue/Green deployment only on `main` branch merge."
"Add a GitHub Actions workflow for automated security scanning (Trivy, tfsec, npm audit) on every PR."
"Create a GitHub Actions workflow to build, test, and deploy Lambda functions to AWS using SAM CLI."
"Add a workflow to run integration tests against a live ECS service after deployment."
"Configure GitHub Actions to cache npm and Terraform providers for faster CI runs."
```


### ECS, Scaling & Observability
```
"Add ECS Service auto scaling policy based on memory usage along with CPU."
"Configure ECS Service to use Spot and Fargate capacity providers for cost optimization."
"Add CloudWatch alarm and SNS notification for ECS task failures or unhealthy deployments."
"Write a script to automate ECS task definition versioning and rollback on deployment failure."
"Add Terraform module to provision OpenSearch (Elasticsearch) domain for centralized log analytics."
"Instrument Next.js app with AWS X-Ray for distributed tracing."
"Configure Prometheus and Grafana dashboards for ECS/EKS metrics and custom app KPIs."
"Set up CloudWatch synthetics canaries to monitor API uptime and latency."
```

---


## Security Engineer
*Focus: IAM, compliance, secrets, security scanning, S3 policies.*
```
"Add IAM policy to enforce least privilege for Lambda, ECS, and CI/CD roles."
"Write a Terraform module to enable GuardDuty, Security Hub, and AWS Config for continuous compliance."
"Configure S3 bucket policies for public access blocking and server-side encryption."
"Add GitHub Actions workflow to check for secrets in code using git-secrets or truffleHog."
```

---


## MLOps & AI Engineer
*Focus: Bedrock Claude, SageMaker, Lambda, RAG, analytics, hybrid AI/ML workflows.*

### Bedrock AI & Lambda
```
"Add Lambda function to trigger Claude summarization for new CloudWatch log group events."
"Integrate AWS Bedrock Claude with S3 event triggers for real-time document summarization."
"Create a Lambda function to invoke Bedrock Claude for RAG (Retrieval-Augmented Generation) workflows."
"Add a workflow to summarize ECS/ALB logs and store insights in DynamoDB for analytics."
```

### SageMaker & MLOps
```
"Provision SageMaker notebook instance and training job pipeline with Terraform."
"Add Lambda function to trigger SageMaker endpoint for real-time inference from Next.js API."
"Write a workflow to automate model retraining and deployment on new data arrival in S3."
"Integrate Bedrock Claude and SageMaker for hybrid AI/ML workflows (summarization + prediction)."
```

---


## Fullstack/Next.js Developer
*Focus: Next.js API, SSR/ISR, auth, environment variables, API integration.*
```
"Update Next.js API route to fetch DB URI from Secrets Manager injected environment variable."
"Add Next.js middleware to enforce JWT authentication using Cognito or Auth0."
"Implement server-side rendering (SSR) with incremental static regeneration (ISR) for feedback pages."
"Add API route to proxy requests to Bedrock Claude for AI-powered feedback analysis."
"Configure Next.js app to use environment variables from AWS Parameter Store in production."
```

---

## Cloud Architect
*Focus: Multi-account, multi-region, networking, cost, and governance.*
```
"Design a Terraform module for a multi-account AWS landing zone with centralized logging and security controls."
"Write a prompt to generate a cost breakdown report for all AWS resources in use."
"Add a module to automate VPC peering and Transit Gateway setup across regions."
"Create a Terraform module for cross-region DynamoDB global tables with KMS encryption."
"Write a workflow to automate backup and disaster recovery for all stateful AWS services."
```

---

## SRE/Observability Engineer
*Focus: SLOs, alerting, chaos engineering, reliability, advanced monitoring.*
```
"Add a workflow to inject chaos (CPU/network faults) into ECS tasks and monitor recovery."
"Configure alerting for SLO/SLA breaches using CloudWatch and PagerDuty."
"Write a script to export CloudWatch metrics to Prometheus for long-term retention."
"Add a workflow to test failover and recovery for multi-AZ RDS and ECS services."
"Create a dashboard to visualize error budgets and reliability KPIs for all services."
```

---

## General/Meta
*Focus: Documentation, onboarding, repo hygiene, team enablement.*
```
"Generate a technical onboarding guide for new engineers joining the FeedbackHub project."
"Write a GitHub Actions workflow to enforce PR title and description standards."
"Add a script to auto-generate and update the Table of Contents for all Markdown docs."
"Create a prompt to summarize the architecture and deployment patterns for recruiters."
"Write a workflow to check for outdated dependencies and open PRs to update them."
```
