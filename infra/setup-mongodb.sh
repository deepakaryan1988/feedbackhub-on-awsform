#!/bin/bash

# MongoDB Atlas Setup Script for FeedbackHub
# This script helps you set up a MongoDB Atlas cluster

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗄️  MongoDB Atlas Setup for FeedbackHub${NC}"
echo ""

echo -e "${YELLOW}📋 To set up MongoDB Atlas for FeedbackHub, follow these steps:${NC}"
echo ""
echo "1. Go to https://cloud.mongodb.com"
echo "2. Sign up for a free account (or sign in if you have one)"
echo "3. Create a new project called 'FeedbackHub'"
echo "4. Create a free cluster (M0 tier) in your preferred region"
echo "5. Set up database access:"
echo "   - Username: feedbackhub"
echo "   - Password: [create a strong password]"
echo "6. Set up network access:"
echo "   - Add IP Address: 0.0.0.0/0 (for development)"
echo "7. Get your connection string"
echo ""

echo -e "${GREEN}🔗 Your connection string will look like this:${NC}"
echo "mongodb+srv://feedbackhub:[password]@cluster0.xxxxx.mongodb.net/feedbackhub?retryWrites=true&w=majority"
echo ""

echo -e "${YELLOW}📝 Once you have your connection string, update terraform.tfvars:${NC}"
echo "1. Replace the mongodb_uri value with your actual connection string"
echo "2. Make sure to replace [password] with your actual password"
echo ""

echo -e "${BLUE}🚀 After updating terraform.tfvars, run:${NC}"
echo "terraform plan"
echo "terraform apply"
echo ""

# Check if terraform.tfvars exists and show current mongodb_uri
if [ -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}📄 Current mongodb_uri in terraform.tfvars:${NC}"
    grep "mongodb_uri" terraform.tfvars | head -1
    echo ""
fi

echo -e "${GREEN}✅ Setup instructions complete!${NC}" 