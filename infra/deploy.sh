#!/bin/bash

# FeedbackHub Infrastructure Deployment Script
# Usage: ./deploy.sh [environment]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default environment
ENVIRONMENT=${1:-production}

echo -e "${BLUE}🚀 FeedbackHub Infrastructure Deployment${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed${NC}"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS credentials not configured${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
    echo ""
}

# Initialize Terraform
init_terraform() {
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
    echo -e "${GREEN}✅ Terraform initialized${NC}"
    echo ""
}

# Plan deployment
plan_deployment() {
    echo -e "${YELLOW}Planning deployment...${NC}"
    terraform plan -var="environment=${ENVIRONMENT}" -out=tfplan
    echo -e "${GREEN}✅ Deployment plan created${NC}"
    echo ""
}

# Apply deployment
apply_deployment() {
    echo -e "${YELLOW}Applying deployment...${NC}"
    terraform apply tfplan
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo ""
}

# Show outputs
show_outputs() {
    echo -e "${BLUE}📊 Deployment Outputs:${NC}"
    echo ""
    
    # Get application URL
    APP_URL=$(terraform output -raw application_url 2>/dev/null || echo "Not available")
    echo -e "${GREEN}🌐 Application URL: ${APP_URL}${NC}"
    
    # Get ALB DNS name
    ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "Not available")
    echo -e "${GREEN}🔗 Load Balancer DNS: ${ALB_DNS}${NC}"
    
    # Get ECS cluster name
    CLUSTER_NAME=$(terraform output -raw ecs_cluster_name 2>/dev/null || echo "Not available")
    echo -e "${GREEN}📦 ECS Cluster: ${CLUSTER_NAME}${NC}"
    
    # Get CloudWatch dashboard
    DASHBOARD_NAME=$(terraform output -raw dashboard_name 2>/dev/null || echo "Not available")
    if [ "$DASHBOARD_NAME" != "Not available" ]; then
        echo -e "${GREEN}📈 CloudWatch Dashboard: ${DASHBOARD_NAME}${NC}"
    fi
    
    echo ""
}

# Main deployment flow
main() {
    check_prerequisites
    init_terraform
    plan_deployment
    
    echo -e "${YELLOW}Do you want to proceed with the deployment? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apply_deployment
        show_outputs
    else
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
}

# Handle script arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        echo "Usage: $0 [environment]"
        echo ""
        echo "Environments:"
        echo "  production  - Deploy to production (default)"
        echo "  staging     - Deploy to staging"
        echo "  development - Deploy to development"
        echo ""
        echo "Examples:"
        echo "  $0              # Deploy to production"
        echo "  $0 staging      # Deploy to staging"
        echo "  $0 development  # Deploy to development"
        exit 0
        ;;
    *)
        main
        ;;
esac 