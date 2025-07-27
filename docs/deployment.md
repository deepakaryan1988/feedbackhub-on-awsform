# Deployment Guide

This guide provides step-by-step instructions for deploying the FeedbackHub application to AWS using Terraform and Docker.

## Prerequisites

### Required Tools
- **AWS CLI**: Configured with appropriate credentials
- **Terraform**: Version 1.0 or higher
- **Docker**: For building and pushing images
- **Node.js**: For local development and testing

### AWS Requirements
- **AWS Account**: With appropriate permissions
- **S3 Bucket**: For Terraform state storage
- **DynamoDB Table**: For Terraform state locking (optional)
- **VPC**: With public and private subnets

## Environment Setup

### 1. AWS Configuration
```bash
# Configure AWS CLI
aws configure

# Verify configuration
aws sts get-caller-identity
```

### 2. Environment Variables
Copy the example environment file and configure it:
```bash
cp env.example .env
```

Required environment variables:
```bash
# MongoDB Atlas
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/feedbackhub

# AWS Configuration
AWS_REGION=ap-south-1
AWS_PROFILE=default

# Application
NODE_ENV=production
PORT=3000
```

## Infrastructure Deployment

### 1. Initialize Terraform
```bash
cd infra/

# Initialize Terraform
terraform init

# Verify configuration
terraform plan
```

### 2. Deploy Infrastructure
```bash
# Apply Terraform configuration
terraform apply

# Verify deployment
terraform output
```

Expected outputs:
- `alb_dns_name`: Application Load Balancer DNS name
- `ecr_repository_url`: ECR repository URL
- `cluster_name`: ECS cluster name

### 3. Configure Secrets
```bash
# Store MongoDB URI in AWS Secrets Manager
aws secretsmanager create-secret \
  --name "feedbackhub/mongodb_uri" \
  --description "MongoDB connection URI for FeedbackHub application" \
  --secret-string "mongodb+srv://username:password@cluster.mongodb.net/feedbackhub" \
  --tags Key=Project,Value=feedbackhub Key=Environment,Value=production
```

## Application Deployment

### 1. Build and Push Docker Image
```bash
# Build and push to ECR
./build-and-push.sh
```

This script:
- Authenticates with ECR
- Builds the Docker image
- Tags the image
- Pushes to ECR repository

### 2. Deploy to ECS
```bash
# Deploy application
./deploy.sh
```

This script:
- Updates the ECS task definition
- Updates the ECS service
- Waits for deployment completion

### 3. Verify Deployment
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Check health endpoint
curl http://$ALB_DNS/api/health

# Check main application
curl http://$ALB_DNS/
```

## Local Development

### 1. Using Docker Compose
```bash
cd docker/

# Start local environment
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop environment
docker-compose down
```

### 2. Using Node.js
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## Monitoring and Troubleshooting

### 1. View Application Logs
```bash
# View ECS logs
aws logs tail /ecs/feedbackhub --follow

# View specific task logs
aws logs get-log-events \
  --log-group-name "/ecs/feedbackhub" \
  --log-stream-name "ecs/feedbackhub/<task-id>"
```

### 2. Check ECS Service Status
```bash
# List ECS services
aws ecs list-services --cluster feedbackhub-production-cluster

# Describe service
aws ecs describe-services \
  --cluster feedbackhub-production-cluster \
  --services feedbackhub-service
```

### 3. Check Task Status
```bash
# List tasks
aws ecs list-tasks --cluster feedbackhub-production-cluster

# Describe tasks
aws ecs describe-tasks \
  --cluster feedbackhub-production-cluster \
  --tasks <task-arn>
```

### 4. Health Check Troubleshooting
```bash
# Test health endpoint
curl -v http://<alb-dns>/api/health

# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

## Scaling and Updates

### 1. Scale Application
```bash
# Update desired count
aws ecs update-service \
  --cluster feedbackhub-production-cluster \
  --service feedbackhub-service \
  --desired-count 3
```

### 2. Update Application
```bash
# Build new image
./build-and-push.sh

# Force new deployment
aws ecs update-service \
  --cluster feedbackhub-production-cluster \
  --service feedbackhub-service \
  --force-new-deployment
```

### 3. Rollback Deployment
```bash
# List task definitions
aws ecs list-task-definitions --family-prefix feedbackhub-task

# Update service to previous revision
aws ecs update-service \
  --cluster feedbackhub-production-cluster \
  --service feedbackhub-service \
  --task-definition feedbackhub-task:<previous-revision>
```

## Cleanup

### 1. Destroy Infrastructure
```bash
cd infra/

# Destroy all resources
terraform destroy
```

### 2. Clean Up Docker Images
```bash
# Remove local images
docker rmi feedbackhub:latest

# Delete ECR repository (if needed)
aws ecr delete-repository --repository-name feedbackhub --force
```

### 3. Clean Up Secrets
```bash
# Delete secrets
aws secretsmanager delete-secret \
  --secret-id feedbackhub/mongodb_uri \
  --force-delete-without-recovery
```

## Best Practices

### 1. Security
- Use IAM roles with least privilege
- Store secrets in AWS Secrets Manager
- Enable VPC flow logs
- Use security groups to restrict access

### 2. Monitoring
- Set up CloudWatch alarms
- Monitor application metrics
- Use structured logging
- Set up log retention policies

### 3. Cost Optimization
- Use appropriate instance sizes
- Enable auto-scaling
- Monitor resource utilization
- Clean up unused resources

### 4. Backup and Recovery
- Regular database backups
- Store Terraform state in S3
- Document recovery procedures
- Test disaster recovery scenarios

This deployment guide ensures a reliable, scalable, and maintainable deployment of the FeedbackHub application. 