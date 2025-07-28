# Complete FeedbackHub Setup Guide

This guide provides step-by-step instructions for setting up FeedbackHub both locally and on AWS.

## 🏠 Local Development Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Docker (optional, for local MongoDB)
- MongoDB Atlas account

### 1. Clone and Install Dependencies
```bash
git clone <repository-url>
cd feedbackhub-on-awsform
npm install
```

### 2. Environment Configuration

#### Option A: MongoDB Atlas (Recommended)
Create `.env.local` file:
```bash
# MongoDB Atlas Configuration
MONGODB_PASSWORD=your-actual-mongodb-password

# Application Configuration
NODE_ENV=development
PORT=3000
NEXT_TELEMETRY_DISABLED=1
```

#### Option B: Local MongoDB with Docker
```bash
cd docker
docker-compose up -d
```

### 3. Start Development Server
```bash
npm run dev
```

### 4. Verify Setup
```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Test main application
curl http://localhost:3000/
```

## ☁️ AWS Deployment Setup

### Prerequisites
- AWS CLI configured
- Terraform >= 1.7.0
- Docker installed
- MongoDB Atlas cluster

### 1. Configure AWS Infrastructure

#### Step 1: Set up Terraform Variables
```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
aws_region = "ap-south-1"
environment = "production"

# VPC Configuration
vpc_id = "vpc-your-vpc-id"
public_subnet_ids = [
  "subnet-public-1",
  "subnet-public-2"
]

# Application Configuration
app_name = "feedbackhub"
ecr_image_url = "your-account.dkr.ecr.ap-south-1.amazonaws.com/feedbackhub:latest"
mongodb_uri = "mongodb+srv://username:password@cluster.mongodb.net/feedbackhub"
```

#### Step 2: Set up MongoDB Atlas
```bash
# Run MongoDB setup script
./setup-mongodb.sh
```

Follow the instructions to:
1. Create MongoDB Atlas cluster
2. Set up database users
3. Configure network access
4. Get connection string

#### Step 3: Build and Push Docker Image
```bash
# Build and push to ECR
./build-and-push.sh
```

#### Step 4: Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### 2. Verify AWS Deployment

#### Check Application Health
```bash
# Get application URL
APP_URL=$(terraform output -raw application_url)
curl $APP_URL/api/health
```

#### Monitor Deployment
```bash
# View ECS logs
aws logs tail /ecs/feedbackhub --follow

# Check ECS service status
aws ecs describe-services \
  --cluster feedbackhub-production-cluster \
  --services feedbackhub-service
```

## 🔧 Testing and Validation

### Local Testing
```bash
# Test MongoDB connection
./scripts/test-mongodb-connection.sh

# Test environment variables
./scripts/test-environments.sh

# Test application endpoints
curl http://localhost:3000/api/health
curl http://localhost:3000/api/feedback
```

### AWS Testing
```bash
# Test health endpoint
curl https://your-alb-dns/api/health

# Test feedback submission
curl -X POST https://your-alb-dns/api/feedback \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","message":"Test feedback"}'
```

## 🛠️ Troubleshooting

### Local Issues

#### MongoDB Connection Failed
```bash
# Check MongoDB Atlas network access
# Verify credentials in .env.local
# Test connection directly
mongosh "mongodb+srv://username:password@cluster.mongodb.net/feedbackhub"
```

#### Application Won't Start
```bash
# Check Node.js version
node --version

# Clear Next.js cache
rm -rf .next
npm run dev
```

### AWS Issues

#### ECS Service Not Starting
```bash
# Check ECS task logs
aws logs get-log-events \
  --log-group-name "/ecs/feedbackhub" \
  --log-stream-name "ecs/feedbackhub/<task-id>"

# Check task definition
aws ecs describe-task-definition \
  --task-definition feedbackhub-task
```

#### Load Balancer Health Check Failing
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Check security groups
aws ec2 describe-security-groups \
  --group-ids <security-group-id>
```

## 📊 Monitoring

### Local Monitoring
- Application logs in terminal
- MongoDB Atlas dashboard
- Browser developer tools

### AWS Monitoring
- CloudWatch logs
- CloudWatch metrics
- Application Load Balancer access logs
- ECS service metrics

## 🔒 Security Best Practices

### Local Development
- Use `.env.local` for sensitive data
- Never commit `.env.local` to git
- Use strong MongoDB passwords
- Enable MongoDB Atlas network access controls

### AWS Production
- Use AWS Secrets Manager for credentials
- Enable VPC flow logs
- Use security groups to restrict access
- Enable CloudTrail for audit logging
- Regular credential rotation

## 🚀 Next Steps

### For Local Development
1. Set up your MongoDB Atlas cluster
2. Create `.env.local` with your credentials
3. Test the application locally
4. Submit feedback and verify storage

### For AWS Deployment
1. Configure your VPC and subnets
2. Set up MongoDB Atlas production cluster
3. Deploy infrastructure with Terraform
4. Monitor application health
5. Set up alerts and monitoring

## 📚 Additional Resources

- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Next.js Documentation](https://nextjs.org/docs)

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review application logs
3. Verify environment configuration
4. Test individual components
5. Check AWS CloudWatch logs for deployment issues 