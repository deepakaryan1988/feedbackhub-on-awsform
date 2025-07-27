# Infrastructure Overview

This document provides an overview of the AWS infrastructure used to deploy the FeedbackHub application.

## Architecture Overview

The FeedbackHub application is deployed on AWS using a modern, scalable architecture:

```
Internet
    │
    ▼
┌─────────────────┐
│   Route 53      │  ← DNS (if configured)
└─────────────────┘
    │
    ▼
┌─────────────────┐
│   ALB           │  ← Application Load Balancer
│   (Port 80)     │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│   ECS Fargate   │  ← Containerized Application
│   (Port 3000)   │
└─────────────────┘
    │
    ▼
┌─────────────────┐
│ MongoDB Atlas   │  ← External Database
└─────────────────┘
```

## Infrastructure Components

### 1. Application Load Balancer (ALB)
- **Purpose**: Distributes incoming traffic to ECS tasks
- **Port**: 80 (HTTP)
- **Health Checks**: `/api/health` endpoint
- **Security**: HTTPS termination (if configured)
- **Location**: `terraform/alb/`

### 2. ECS Fargate Cluster
- **Purpose**: Runs containerized application
- **Service**: `feedbackhub-service`
- **Task Definition**: `feedbackhub-task`
- **Scaling**: Auto-scaling based on CPU/memory
- **Location**: `terraform/ecs/`

### 3. Container Registry (ECR)
- **Purpose**: Stores Docker images
- **Repository**: `feedbackhub`
- **Image**: Multi-stage build for optimization
- **Security**: IAM-based access control

### 4. Secrets Management
- **Purpose**: Secure storage of sensitive data
- **Secret**: `feedbackhub/mongodb_uri`
- **Access**: ECS task execution role
- **Location**: `terraform/secrets/`

### 5. CloudWatch Logs
- **Purpose**: Application logging and monitoring
- **Log Group**: `/ecs/feedbackhub`
- **Retention**: 30 days
- **Location**: `terraform/cloudwatch/`

### 6. IAM Roles
- **Task Role**: Permissions for application
- **Execution Role**: Permissions for ECS to pull images and secrets

## Terraform Organization

### Modular Structure
```
terraform/
├── alb/                    # Application Load Balancer
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── cloudwatch/             # CloudWatch Logs
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ecs/                    # ECS Cluster and Service
│   ├── cluster/
│   ├── feedbackhub/
│   └── feedbackhub_service/
└── secrets/                # AWS Secrets Manager
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

### Composition Layer
```
infra/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output values
├── provider.tf             # AWS provider configuration
├── backend.tf              # S3 backend configuration
└── versions.tf             # Terraform version constraints
```

## Security Considerations

### Network Security
- **VPC**: Isolated network environment
- **Security Groups**: Restrictive access rules
- **Subnets**: Public and private subnet separation

### Application Security
- **Secrets**: MongoDB URI stored in AWS Secrets Manager
- **IAM**: Least privilege access
- **Container**: Non-root user execution

### Data Security
- **Encryption**: Data encrypted in transit and at rest
- **Backup**: MongoDB Atlas automated backups
- **Access Control**: Database user with minimal permissions

## Monitoring and Observability

### CloudWatch Integration
- **Logs**: Structured application logging
- **Metrics**: ECS service metrics
- **Alarms**: Health check failures
- **Dashboards**: Application performance monitoring

### Health Checks
- **Endpoint**: `/api/health`
- **Checks**: Database connectivity
- **Response**: JSON with service status

## Deployment Process

### 1. Infrastructure Deployment
```bash
cd infra/
terraform init
terraform plan
terraform apply
```

### 2. Application Deployment
```bash
# Build and push Docker image
./build-and-push.sh

# Deploy to ECS
./deploy.sh
```

### 3. Verification
```bash
# Check service health
curl http://<alb-dns>/api/health

# View logs
aws logs tail /ecs/feedbackhub --follow
```

## Cost Optimization

### Resource Sizing
- **ECS Tasks**: 0.5 vCPU, 1GB RAM (suitable for development)
- **ALB**: Single AZ for cost reduction
- **Logs**: 30-day retention policy

### Scaling Strategy
- **Auto Scaling**: Based on CPU utilization
- **Min/Max**: 1-3 tasks for development
- **Target**: 70% CPU utilization

## Disaster Recovery

### Backup Strategy
- **Database**: MongoDB Atlas automated backups
- **Infrastructure**: Terraform state in S3
- **Application**: Docker images in ECR

### Recovery Procedures
1. **Infrastructure**: Recreate with Terraform
2. **Application**: Redeploy from ECR
3. **Data**: Restore from MongoDB Atlas backups

This infrastructure provides a robust, scalable, and cost-effective platform for the FeedbackHub application while following AWS best practices. 