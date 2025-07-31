#!/bin/bash

# Comprehensive Bedrock Integration Test
echo "🧪 Bedrock Integration Test Suite"
echo "=================================="

ALB_URL="http://feedbackhub-production-alb-1657244829.ap-south-1.elb.amazonaws.com"

echo "📋 ALB URL: $ALB_URL"
echo ""

# Step 1: Generate various types of errors
echo "🔍 Step 1: Generating Application Errors..."
echo "----------------------------------------"

# Test 1: 404 Error
echo "📝 Test 1: 404 Error (Non-existent endpoint)"
curl -s -w "\nHTTP Status: %{http_code}\n" "$ALB_URL/non-existent-endpoint" || true

echo ""
echo "⏳ Waiting 5 seconds..."
sleep 5

# Test 2: Invalid JSON Error
echo "📝 Test 2: Invalid JSON Error"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$ALB_URL/api/feedback" \
  -H "Content-Type: application/json" \
  -d '{invalid json}' || true

echo ""
echo "⏳ Waiting 5 seconds..."
sleep 5

# Test 3: Malformed Request Error
echo "📝 Test 3: Malformed Request Error"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$ALB_URL/api/feedback" \
  -H "Content-Type: application/json" \
  -d '{"invalid": "data"}' || true

echo ""
echo "⏳ Waiting 10 seconds for logs to be processed..."
sleep 10

# Step 2: Check CloudWatch Logs
echo ""
echo "🔍 Step 2: Checking CloudWatch Logs..."
echo "--------------------------------------"
aws logs tail /ecs/feedbackhub --since 2m --no-cli-pager

echo ""
echo "⏳ Waiting 15 seconds for Lambda processing..."
sleep 15

# Step 3: Check Lambda Logs
echo ""
echo "🔍 Step 3: Checking Lambda Logs..."
echo "----------------------------------"
aws logs tail /aws/lambda/feedbackhub-production-bedrock-log-summarizer --since 2m --no-cli-pager

# Step 4: Check S3 Bucket
echo ""
echo "🔍 Step 4: Checking S3 Bucket..."
echo "--------------------------------"
aws s3 ls s3://feedbackhub-production-lambda-summaries/log-summaries/ --recursive --no-cli-pager

# Step 5: Get latest summary
echo ""
echo "🔍 Step 5: Latest Summary Content..."
echo "------------------------------------"
LATEST_FILE=$(aws s3 ls s3://feedbackhub-production-lambda-summaries/log-summaries/ --recursive --no-cli-pager | tail -1 | awk '{print $4}')
if [ ! -z "$LATEST_FILE" ]; then
    echo "📄 Latest summary file: $LATEST_FILE"
    aws s3 cp "s3://feedbackhub-production-lambda-summaries/$LATEST_FILE" /tmp/latest_summary.json --no-cli-pager
    cat /tmp/latest_summary.json | jq '.' 2>/dev/null || cat /tmp/latest_summary.json
else
    echo "❌ No summary files found"
fi

echo ""
echo "✅ Test Complete!"
echo ""
echo "📸 Screenshot Suggestions:"
echo "1. CloudWatch Logs Console: /ecs/feedbackhub"
echo "2. Lambda Function Console: /aws/lambda/feedbackhub-production-bedrock-log-summarizer"
echo "3. S3 Console: feedbackhub-production-lambda-summaries bucket"
echo "4. AWS CLI Output (above) showing the complete flow" 