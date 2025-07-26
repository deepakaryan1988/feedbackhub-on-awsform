#!/bin/bash

# Script to get VPC and subnet information for Terraform configuration
# Usage: ./get-vpc-info.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Fetching VPC and Subnet Information from AWS...${NC}"
echo ""

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${YELLOW}❌ AWS CLI not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Get the current region
REGION=$(aws configure get region || echo "us-east-1")
echo -e "${GREEN}📍 AWS Region: ${REGION}${NC}"

# Get default VPC
echo -e "${YELLOW}📋 Getting default VPC...${NC}"
DEFAULT_VPC=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")

if [ -z "$DEFAULT_VPC" ] || [ "$DEFAULT_VPC" = "None" ]; then
    echo -e "${YELLOW}⚠️  No default VPC found. Getting first available VPC...${NC}"
    DEFAULT_VPC=$(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")
fi

if [ -z "$DEFAULT_VPC" ] || [ "$DEFAULT_VPC" = "None" ]; then
    echo -e "${YELLOW}❌ No VPCs found. Please create a VPC first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ VPC ID: ${DEFAULT_VPC}${NC}"

# Get public subnets
echo -e "${YELLOW}📋 Getting public subnets...${NC}"
PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=${DEFAULT_VPC}" "Name=map-public-ip-on-launch,Values=true" \
    --query 'Subnets[*].SubnetId' \
    --output text 2>/dev/null || echo "")

if [ -z "$PUBLIC_SUBNETS" ]; then
    echo -e "${YELLOW}⚠️  No public subnets found. Getting all subnets...${NC}"
    PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=${DEFAULT_VPC}" \
        --query 'Subnets[0:2].SubnetId' \
        --output text 2>/dev/null || echo "")
fi

if [ -z "$PUBLIC_SUBNETS" ]; then
    echo -e "${YELLOW}❌ No subnets found. Please create subnets first.${NC}"
    exit 1
fi

# Convert space-separated to array format
SUBNET_ARRAY=$(echo $PUBLIC_SUBNETS | tr ' ' '\n' | head -2 | tr '\n' ' ' | sed 's/ $//')

echo -e "${GREEN}✅ Public Subnets: ${SUBNET_ARRAY}${NC}"
echo ""

# Generate terraform.tfvars content
echo -e "${BLUE}📝 Generated terraform.tfvars configuration:${NC}"
echo ""

cat > terraform.tfvars << EOF
# AWS Configuration
aws_region = "${REGION}"
environment = "production"

# VPC Configuration - Auto-detected from AWS
vpc_id = "${DEFAULT_VPC}"
public_subnet_ids = [
  $(echo $SUBNET_ARRAY | tr ' ' '\n' | sed 's/^/  "/' | sed 's/$/",/' | head -2)
]

# Application Configuration
app_name = "feedbackhub"
ecr_image_url = "123456789012.dkr.ecr.${REGION}.amazonaws.com/feedbackhub:latest"
mongodb_uri = "mongodb+srv://feedbackhub:password123@cluster0.mongodb.net/feedbackhub?retryWrites=true&w=majority"
app_port = 3000

# ECS Configuration - Optimized for production
ecs_cpu = 512          # 0.5 vCPU
ecs_memory = 1024      # 1 GB RAM
ecs_desired_count = 2  # 2 tasks for high availability
ecs_min_capacity = 1   # Minimum 1 task
ecs_max_capacity = 5   # Maximum 5 tasks for auto-scaling

# Monitoring Configuration
log_retention_days = 30
create_cloudwatch_dashboard = true
create_cloudwatch_alarms = true
cpu_threshold = 70     # Scale up when CPU > 70%
memory_threshold = 80  # Scale up when Memory > 80%

# Additional Tags
tags = {
  Owner       = "devops-team"
  CostCenter  = "engineering"
  Project     = "feedbackhub"
  Environment = "production"
  ManagedBy   = "terraform"
}
EOF

echo -e "${GREEN}✅ terraform.tfvars file created successfully!${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Please update the following values before deploying:${NC}"
echo -e "${YELLOW}   1. ecr_image_url: Replace with your actual ECR image URL${NC}"
echo -e "${YELLOW}   2. mongodb_uri: Replace with your actual MongoDB connection string${NC}"
echo ""
echo -e "${BLUE}🚀 Ready to deploy! Run: terraform plan && terraform apply${NC}" 