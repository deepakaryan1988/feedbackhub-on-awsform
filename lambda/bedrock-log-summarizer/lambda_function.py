"""
AWS Lambda function for summarizing ECS logs using AWS Bedrock (Claude Sonnet 4)
This function is triggered by CloudWatch log subscription filters.
"""

import json
import os
import boto3
import logging
import base64
import gzip
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
bedrock_runtime = boto3.client('bedrock-runtime', region_name='ap-south-1')
bedrock = boto3.client('bedrock', region_name='ap-south-1')
logs = boto3.client('logs')
s3 = boto3.client('s3')

# Environment variables
MODEL_ID = os.environ.get('MODEL_ID', 'amazon.titan-text-lite-v1')
LOG_GROUP_NAME = os.environ.get('LOG_GROUP_NAME', '/ecs/feedbackhub')
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
MAX_LOG_LENGTH = int(os.environ.get('MAX_LOG_LENGTH', '10000'))
SUMMARY_INTERVAL = int(os.environ.get('SUMMARY_INTERVAL', '60'))


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function
    """
    try:
        logger.info(f"Processing event: {json.dumps(event)}")
        
        # Extract log data from CloudWatch subscription
        log_data = extract_log_data(event)
        if not log_data:
            logger.warning("No log data found in event")
            return {'statusCode': 200, 'body': 'No log data to process'}
        
        # Truncate logs to control costs
        truncated_logs = truncate_logs(log_data)
        
        # Generate summary using Bedrock
        summary = generate_summary(truncated_logs)
        
        # Log the summary
        logger.info(f"Generated summary: {summary}")
        
        # Save summary to S3 if bucket is configured
        if S3_BUCKET_NAME:
            save_summary_to_s3(summary, log_data)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'summary': summary,
                'logs_processed': len(log_data),
                'timestamp': datetime.utcnow().isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing logs: {str(e)}")
        raise


def extract_log_data(event: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Extract log data from CloudWatch subscription event or manual test event
    Supports both:
    1. CloudWatch subscription events (awslogs.data)
    2. Manual test events with logEvents directly
    """
    log_data = []
    
    # Check if this is a CloudWatch subscription event
    if 'awslogs' in event and 'data' in event['awslogs']:
        logger.info("Processing CloudWatch subscription event")
        for record in event['awslogs']['data']:
            try:
                # Decode and decompress log data
                decoded_data = base64.b64decode(record)
                decompressed_data = gzip.decompress(decoded_data)
                log_events = json.loads(decompressed_data)
                
                # Extract log events
                for log_event in log_events.get('logEvents', []):
                    log_data.append({
                        'timestamp': log_event.get('timestamp'),
                        'message': log_event.get('message', ''),
                        'logStreamName': log_events.get('logStream')
                    })
                    
            except Exception as e:
                logger.error(f"Error extracting log data from CloudWatch subscription: {str(e)}")
                continue
    
    # Check if this is a manual test event with logEvents directly
    elif 'logEvents' in event:
        logger.info("Processing manual test event with logEvents")
        current_timestamp = int(datetime.utcnow().timestamp() * 1000)
        
        for log_event in event['logEvents']:
            # Use provided timestamp or current time if not provided
            timestamp = log_event.get('timestamp', current_timestamp)
            message = log_event.get('message', '')
            
            log_data.append({
                'timestamp': timestamp,
                'message': message,
                'logStreamName': 'manual-test'
            })
    
    else:
        logger.warning("Event format not recognized. Expected 'awslogs.data' or 'logEvents'")
    
    return log_data


def truncate_logs(log_data: List[Dict[str, Any]]) -> str:
    """
    Truncate logs to control costs and prepare for summarization
    """
    # Sort logs by timestamp
    sorted_logs = sorted(log_data, key=lambda x: x.get('timestamp', 0))
    
    # Combine log messages
    combined_logs = []
    total_length = 0
    
    for log in sorted_logs:
        message = log.get('message', '')
        timestamp = datetime.fromtimestamp(log.get('timestamp', 0) / 1000).strftime('%Y-%m-%d %H:%M:%S')
        
        log_entry = f"[{timestamp}] {message}"
        
        if total_length + len(log_entry) > MAX_LOG_LENGTH:
            break
            
        combined_logs.append(log_entry)
        total_length += len(log_entry)
    
    return '\n'.join(combined_logs)


def generate_summary(logs_text: str) -> str:
    """
    Generate summary using AWS Bedrock (Claude Sonnet 4)
    """
    if not logs_text.strip():
        return "No logs to summarize"
    
    # Prepare prompt for Claude
    prompt = f"""
You are a log analysis expert. Please analyze the following ECS application logs and provide a concise summary.

Focus on:
1. Error patterns and frequency
2. Performance issues or bottlenecks
3. Application behavior trends
4. Any critical issues that need attention

Logs:
{logs_text}

Please provide a clear, actionable summary in 2-3 paragraphs.
"""
    
    try:
        # First, try to find an available inference profile for Claude Sonnet 4
        inference_profile_arn = None
        
        try:
            # List inference profiles to find one with Claude Sonnet 4
            profiles_response = bedrock.list_inference_profiles()
            
            for profile in profiles_response.get('inferenceProfiles', []):
                model_arn = profile.get('modelArn', '')
                if 'claude-sonnet-4' in model_arn.lower():
                    inference_profile_arn = profile.get('inferenceProfileArn')
                    logger.info(f"Found inference profile for Claude Sonnet 4: {inference_profile_arn}")
                    break
            
            if not inference_profile_arn:
                logger.warning("No inference profile found for Claude Sonnet 4, trying direct model invocation")
                
        except Exception as e:
            logger.warning(f"Could not list inference profiles: {str(e)}, trying direct model invocation")
        
        # Prepare request body for Titan
        request_body = {
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": 1000,
                "temperature": 0.7,
                "topP": 0.9
            }
        }
        
        # Call Bedrock API - use inference profile if available, otherwise use model ID
        if inference_profile_arn:
            response = bedrock_runtime.invoke_model(
                modelId=inference_profile_arn,
                body=json.dumps(request_body),
                contentType='application/json'
            )
        else:
            response = bedrock_runtime.invoke_model(
                modelId=MODEL_ID,
                body=json.dumps(request_body),
                contentType='application/json'
            )
        
        response_body = json.loads(response['body'].read())
        
        # Extract summary from response (Titan format)
        summary = response_body['results'][0]['outputText']
        
        return summary.strip()
        
    except Exception as e:
        logger.error(f"Error calling Bedrock API: {str(e)}")
        return f"Error generating summary: {str(e)}"


def save_summary_to_s3(summary: str, log_data: List[Dict[str, Any]]) -> None:
    """
    Save summary to S3 bucket
    """
    try:
        timestamp = datetime.utcnow().strftime('%Y-%m-%d-%H-%M-%S')
        key = f"log-summaries/{LOG_GROUP_NAME.replace('/', '-')}/{timestamp}.json"
        
        summary_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'log_group': LOG_GROUP_NAME,
            'logs_processed': len(log_data),
            'summary': summary,
            'model_used': MODEL_ID
        }
        
        s3.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=key,
            Body=json.dumps(summary_data, indent=2),
            ContentType='application/json'
        )
        
        logger.info(f"Summary saved to S3: s3://{S3_BUCKET_NAME}/{key}")
        
    except Exception as e:
        logger.error(f"Error saving summary to S3: {str(e)}")


def get_recent_logs() -> List[Dict[str, Any]]:
    """
    Get recent logs from CloudWatch for manual summarization
    """
    try:
        # Get log streams
        streams_response = logs.describe_log_streams(
            logGroupName=LOG_GROUP_NAME,
            orderBy='LastEventTime',
            descending=True,
            maxItems=5
        )
        
        log_data = []
        
        for stream in streams_response.get('logStreams', []):
            # Get log events from the last hour
            end_time = int(datetime.utcnow().timestamp() * 1000)
            start_time = int((datetime.utcnow() - timedelta(hours=1)).timestamp() * 1000)
            
            events_response = logs.get_log_events(
                logGroupName=LOG_GROUP_NAME,
                logStreamName=stream['logStreamName'],
                startTime=start_time,
                endTime=end_time
            )
            
            for event in events_response.get('events', []):
                log_data.append({
                    'timestamp': event.get('timestamp'),
                    'message': event.get('message', ''),
                    'logStreamName': stream['logStreamName']
                })
        
        return log_data
        
    except Exception as e:
        logger.error(f"Error getting recent logs: {str(e)}")
        return [] 