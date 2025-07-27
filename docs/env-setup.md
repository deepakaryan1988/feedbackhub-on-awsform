# Environment Setup Guide

This guide provides detailed instructions for setting up the development and production environments for the FeedbackHub application.

## Development Environment

### Prerequisites

#### 1. Node.js and npm
```bash
# Install Node.js 20.x (LTS)
# macOS (using Homebrew)
brew install node@20

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be v20.x.x
npm --version   # Should be 8.x.x or higher
```

#### 2. Docker and Docker Compose
```bash
# macOS
brew install --cask docker

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker-compose --version
```

#### 3. Git
```bash
# macOS
brew install git

# Ubuntu/Debian
sudo apt-get install git

# Verify installation
git --version
```

### Local Development Setup

#### 1. Clone Repository
```bash
git clone <repository-url>
cd feedbackhub-on-awsform
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Environment Configuration
```bash
# Copy environment example
cp env.example .env

# Edit environment variables
nano .env
```

Required environment variables for local development:
```bash
# MongoDB Atlas (for production-like testing)
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/feedbackhub

# Application
NODE_ENV=development
PORT=3000

# Next.js
NEXT_TELEMETRY_DISABLED=1
```

#### 4. Start Development Server
```bash
# Using Node.js directly
npm run dev

# Using Docker Compose (recommended for full-stack testing)
cd docker/
docker-compose up -d
```

#### 5. Verify Setup
```bash
# Check if application is running
curl http://localhost:3000/api/health

# Open in browser
open http://localhost:3000
```

## Production Environment

### AWS Setup

#### 1. AWS CLI Configuration
```bash
# Install AWS CLI
# macOS
brew install awscli

# Ubuntu/Debian
sudo apt-get install awscli

# Configure AWS CLI
aws configure

# Enter your credentials:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: ap-south-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

#### 2. Required AWS Permissions
Your AWS user/role needs the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "elasticloadbalancing:*",
        "iam:*",
        "logs:*",
        "secretsmanager:*",
        "s3:*",
        "dynamodb:*",
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 3. Terraform Setup
```bash
# Install Terraform
# macOS
brew install terraform

# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform --version
```

### MongoDB Atlas Setup

#### 1. Create MongoDB Atlas Cluster
1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Create a new project
3. Build a new cluster (M0 Free tier recommended)
4. Choose cloud provider and region

#### 2. Configure Database Access
1. Go to Database Access
2. Add new database user:
   - **Username**: `feedbackhub`
   - **Password**: Generate a secure password
   - **Database User Privileges**: "Read and write to any database"
3. Save the credentials

#### 3. Configure Network Access
1. Go to Network Access
2. Add IP Address:
   - **IP Address**: `0.0.0.0/0` (for development)
   - **Comment**: "Allow all IPs for development"
3. For production, add specific AWS VPC CIDR ranges

#### 4. Get Connection String
1. Go to Database
2. Click "Connect"
3. Choose "Connect your application"
4. Copy the connection string
5. Replace `<password>` with your database user password

### Infrastructure Setup

#### 1. S3 Backend Setup (Optional but Recommended)
```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://feedbackhub-terraform-state

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket feedbackhub-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name feedbackhub-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

#### 2. Configure Terraform Backend
Edit `infra/backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "feedbackhub-terraform-state"
    key            = "feedbackhub/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "feedbackhub-terraform-locks"
    encrypt        = true
  }
}
```

#### 3. Configure Terraform Variables
Edit `infra/terraform.tfvars`:
```hcl
# Project configuration
project_name = "feedbackhub"
environment  = "production"
region       = "ap-south-1"

# VPC configuration
vpc_cidr = "10.0.0.0/16"

# ECS configuration
ecs_cpu    = 512
ecs_memory = 1024

# Tags
tags = {
  Project     = "feedbackhub"
  Environment = "production"
  Owner       = "devops-team"
  ManagedBy   = "terraform"
}
```

## Environment Variables Reference

### Development Environment (.env)
```bash
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/feedbackhub

# Application
NODE_ENV=development
PORT=3000

# Next.js
NEXT_TELEMETRY_DISABLED=1

# AWS (for local testing)
AWS_REGION=ap-south-1
AWS_PROFILE=default
```

### Production Environment (ECS Task Definition)
```bash
# Database (from AWS Secrets Manager)
MONGODB_URI=arn:aws:secretsmanager:region:account:secret:feedbackhub/mongodb_uri

# Application
NODE_ENV=production
PORT=3000

# Next.js
NEXT_TELEMETRY_DISABLED=1

# AWS
AWS_REGION=ap-south-1
```

### Docker Environment (docker-compose.yml)
```yaml
environment:
  - MONGODB_URI=mongodb://mongo:27017/feedbackhub
  - NODE_ENV=production
  - PORT=3000
```

## Troubleshooting

### Common Issues

#### 1. Node.js Version Issues
```bash
# Check Node.js version
node --version

# Use nvm to manage Node.js versions
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

#### 2. Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker
```

#### 3. AWS CLI Configuration Issues
```bash
# Check AWS configuration
aws configure list

# Test AWS credentials
aws sts get-caller-identity

# Set default region
aws configure set default.region ap-south-1
```

#### 4. Terraform State Issues
```bash
# Initialize Terraform
cd infra/
terraform init

# Check state
terraform state list

# Import existing resources (if needed)
terraform import aws_ecs_cluster.main cluster-name
```

#### 5. MongoDB Connection Issues
```bash
# Test MongoDB connection
mongosh "mongodb+srv://username:password@cluster.mongodb.net/feedbackhub"

# Check network access in MongoDB Atlas
# Verify IP whitelist includes your IP or 0.0.0.0/0
```

### Performance Optimization

#### 1. Development
- Use `npm ci` instead of `npm install` for faster installs
- Enable Next.js caching: `NEXT_TELEMETRY_DISABLED=1`
- Use Docker Compose for consistent environments

#### 2. Production
- Use multi-stage Docker builds
- Enable Next.js standalone output
- Configure appropriate ECS task sizing
- Set up CloudWatch monitoring

## Security Best Practices

### 1. Credentials Management
- Never commit secrets to version control
- Use AWS Secrets Manager for production secrets
- Rotate credentials regularly
- Use IAM roles instead of access keys when possible

### 2. Network Security
- Use VPC with private subnets for ECS tasks
- Configure security groups with minimal required access
- Enable VPC flow logs for monitoring
- Use HTTPS in production

### 3. Application Security
- Keep dependencies updated
- Use non-root user in Docker containers
- Enable security headers in Next.js
- Implement proper input validation

This environment setup guide ensures a secure, scalable, and maintainable development and production environment for the FeedbackHub application. 