# FeedbackHub Infrastructure - Terraform

This directory contains the Terraform configuration for deploying the FeedbackHub application to AWS ECS Fargate.

## 🏗️ Architecture

The infrastructure consists of the following components:

- **ECS Fargate Cluster**: Container orchestration
- **ECS Service**: Runs the FeedbackHub application
- **Application Load Balancer**: Traffic distribution and health checks
- **CloudWatch**: Logging and monitoring
- **Secrets Manager**: Secure storage of MongoDB URI
- **Auto Scaling**: Automatic scaling based on CPU and memory usage

## 📁 Structure

```
infra/
├── main.tf                 # Main infrastructure composition
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── provider.tf             # AWS provider configuration
├── backend.tf              # Remote state configuration (optional)
├── versions.tf             # Terraform and provider versions
├── terraform.tfvars.example # Example variable values
└── README.md               # This file

terraform/
├── ecs/
│   ├── cluster/            # ECS cluster module
│   ├── feedbackhub/        # ECS task definition module
│   └── feedbackhub_service/ # ECS service module
├── alb/                    # Application Load Balancer module
├── cloudwatch/             # CloudWatch monitoring module
└── secrets/                # Secrets Manager module
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.7.0
3. **VPC** with public subnets
4. **ECR repository** with your Docker image
5. **MongoDB** database (Atlas or self-hosted)

### 1. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region = "us-east-1"
environment = "production"

# VPC Configuration
vpc_id = "vpc-your-vpc-id"
public_subnet_ids = [
  "subnet-public-1",
  "subnet-public-2"
]

# Application Configuration
app_name = "feedbackhub"
ecr_image_url = "your-account.dkr.ecr.us-east-1.amazonaws.com/feedbackhub:latest"
mongodb_uri = "mongodb+srv://username:password@cluster.mongodb.net/feedbackhub"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan the Deployment

```bash
terraform plan
```

### 4. Apply the Infrastructure

```bash
terraform apply
```

### 5. Access Your Application

After successful deployment, get the application URL:

```bash
terraform output application_url
```

## 🔧 Configuration Options

### ECS Configuration

- **CPU**: 256 (0.25 vCPU) to 4096 (4 vCPU)
- **Memory**: 512 MiB to 30 GiB
- **Desired Count**: Number of running tasks
- **Auto Scaling**: Min/Max capacity for automatic scaling

### Monitoring Configuration

- **Log Retention**: Days to keep CloudWatch logs
- **Dashboard**: CloudWatch dashboard for metrics
- **Alarms**: CPU and memory utilization alarms
- **Thresholds**: Customizable alarm thresholds

### Security

- **Secrets Manager**: MongoDB URI stored securely
- **IAM Roles**: Least privilege access for ECS tasks
- **Security Groups**: Network-level security controls

## 📊 Monitoring

### CloudWatch Dashboard

Access the CloudWatch dashboard to monitor:
- ECS service metrics (CPU, Memory)
- ALB metrics (Request count, Response time)
- Application logs

### Logs

Application logs are available in CloudWatch Logs:
- Log Group: `/ecs/feedbackhub`
- Stream Prefix: `ecs`

### Alarms

CloudWatch alarms are created for:
- High CPU utilization (>80%)
- High memory utilization (>80%)

## 🔄 Updates and Scaling

### Update Application

To deploy a new version:

1. Push new image to ECR
2. Update `ecr_image_url` in terraform.tfvars
3. Run `terraform apply`

### Manual Scaling

```bash
# Scale to 5 tasks
terraform apply -var="ecs_desired_count=5"
```

### Auto Scaling

The infrastructure includes automatic scaling based on:
- CPU utilization
- Memory utilization

Configure thresholds in `terraform.tfvars`:
```hcl
cpu_threshold = 70
memory_threshold = 80
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all infrastructure including data in Secrets Manager.

## 🔐 Security Best Practices

1. **Use IAM Roles**: ECS tasks use IAM roles with minimal permissions
2. **Secrets Management**: MongoDB URI stored in AWS Secrets Manager
3. **Network Security**: Security groups restrict traffic
4. **Encryption**: All data encrypted in transit and at rest
5. **Logging**: Comprehensive logging for audit trails

## 🐛 Troubleshooting

### Common Issues

1. **VPC/Subnet Issues**: Ensure subnets are in the correct VPC and have internet access
2. **ECR Access**: Verify ECS tasks can pull from ECR
3. **Secrets Access**: Check IAM permissions for Secrets Manager
4. **Health Checks**: Verify `/api/health` endpoint returns 200

### Debug Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster feedbackhub-production-cluster --services feedbackhub-service

# View CloudWatch logs
aws logs tail /ecs/feedbackhub --follow

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## 📚 Additional Resources

- [ECS Fargate Documentation](https://docs.aws.amazon.com/ecs/latest/userguide/what-is-fargate.html)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [CloudWatch Monitoring](https://docs.aws.amazon.com/cloudwatch/)
- [Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)

## 🤝 Contributing

1. Follow Terraform best practices
2. Test changes in a non-production environment
3. Update documentation for any new features
4. Use consistent naming conventions 