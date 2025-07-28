#!/bin/bash

# Build and Push Docker Image to ECR
# Usage: ./build-and-push.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Building and Pushing FeedbackHub Docker Image to ECR${NC}"
echo ""

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --no-cli-pager)
REGION=$(aws configure get region || echo "ap-south-1")
REPO_NAME="feedbackhub"
IMAGE_TAG="latest"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo -e "${GREEN}📍 AWS Account: ${ACCOUNT_ID}${NC}"
echo -e "${GREEN}📍 AWS Region: ${REGION}${NC}"
echo -e "${GREEN}📍 ECR Repository: ${REPO_NAME}${NC}"
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Login to ECR
echo -e "${YELLOW}🔐 Logging in to ECR...${NC}"
aws ecr get-login-password --region ${REGION} --no-cli-pager | docker login --username AWS --password-stdin ${ECR_URI}
echo -e "${GREEN}✅ ECR login successful${NC}"
echo ""

# Build the Docker image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
cd ..
docker build -f docker/Dockerfile.prod -t ${REPO_NAME}:${IMAGE_TAG} .
echo -e "${GREEN}✅ Docker image built successfully${NC}"
echo ""

# Tag the image for ECR
echo -e "${YELLOW}🏷️  Tagging image for ECR...${NC}"
docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URI}/${REPO_NAME}:${IMAGE_TAG}
echo -e "${GREEN}✅ Image tagged for ECR${NC}"
echo ""

# Push the image to ECR
echo -e "${YELLOW}📤 Pushing image to ECR...${NC}"
docker push ${ECR_URI}/${REPO_NAME}:${IMAGE_TAG}
echo -e "${GREEN}✅ Image pushed to ECR successfully!${NC}"
echo ""

# Show the image URI
echo -e "${BLUE}📋 Image URI for terraform.tfvars:${NC}"
echo "ecr_image_url = \"${ECR_URI}/${REPO_NAME}:${IMAGE_TAG}\""
echo ""

# Update terraform.tfvars if it exists
if [ -f "infra/terraform.tfvars" ]; then
    echo -e "${YELLOW}📝 Updating terraform.tfvars with new ECR image URL...${NC}"
    sed -i.bak "s|ecr_image_url = \".*\"|ecr_image_url = \"${ECR_URI}/${REPO_NAME}:${IMAGE_TAG}\"|" infra/terraform.tfvars
    echo -e "${GREEN}✅ terraform.tfvars updated${NC}"
    echo ""
fi

echo -e "${GREEN}🎉 Build and push completed successfully!${NC}"
echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "1. Set up MongoDB Atlas (run: ./setup-mongodb.sh)"
echo "2. Update mongodb_uri in terraform.tfvars"
echo "3. Deploy infrastructure: terraform plan && terraform apply" 