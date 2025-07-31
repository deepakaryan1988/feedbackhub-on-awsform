# Bedrock Log Summarizer - Manual Events Support

## Overview

The Bedrock Log Summarizer Lambda function has been enhanced to support both CloudWatch subscription events and manual test events. This allows for testing and demonstration purposes when there are no live ECS errors.

## Event Formats Supported

### 1. CloudWatch Subscription Events (Production)
```json
{
  "awslogs": {
    "data": [
      "base64-encoded-gzipped-log-data"
    ]
  }
}
```

### 2. Manual Test Events (Testing/Demo)
```json
{
  "logEvents": [
    {
      "timestamp": 1640995200000,
      "message": "ERROR: Database connection failed"
    },
    {
      "message": "WARN: High memory usage detected"
    }
  ]
}
```

## Key Features

### Fallback Logic
- **Primary Path**: Processes CloudWatch subscription events via `awslogs.data`
- **Fallback Path**: Processes manual test events via `logEvents`
- **Graceful Handling**: Logs warnings for unrecognized event formats

### Timestamp Handling
- **With Timestamp**: Uses provided timestamp in milliseconds
- **Without Timestamp**: Uses current UTC timestamp
- **Consistent Format**: All timestamps converted to milliseconds for processing

### Log Stream Identification
- **CloudWatch Events**: Uses actual log stream name
- **Manual Events**: Uses `'manual-test'` as log stream identifier

## Implementation Details

### Updated `extract_log_data()` Function

```python
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
        # ... existing CloudWatch processing logic
    
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
```

## Testing

### Test Scripts Available

1. **Bash Script**: `scripts/test-bedrock-manual-events.sh`
   - Uses AWS CLI to invoke Lambda
   - Tests various event formats
   - Requires `jq` for JSON formatting

2. **Python Script**: `scripts/test-bedrock-manual.py`
   - Uses boto3 for Lambda invocation
   - More detailed error handling
   - Better for development and debugging

### Test Scenarios

1. **Manual Events with Timestamps**
   ```json
   {
     "logEvents": [
       {
         "timestamp": 1640995200000,
         "message": "ERROR: Database connection failed"
       }
     ]
   }
   ```

2. **Manual Events without Timestamps**
   ```json
   {
     "logEvents": [
       {
         "message": "WARN: High memory usage detected"
       }
     ]
   }
   ```

3. **Empty Events**
   ```json
   {
     "logEvents": []
   }
   ```

4. **Invalid Event Format**
   ```json
   {
     "invalid": "data"
   }
   ```

## Usage Examples

### AWS CLI Testing
```bash
aws lambda invoke \
    --function-name feedbackhub-production-bedrock-log-summarizer \
    --payload '{
        "logEvents": [
            {
                "message": "ERROR: Test error message"
            }
        ]
    }' \
    response.json
```

### Python Testing
```python
import boto3
import json

lambda_client = boto3.client('lambda', region_name='ap-south-1')

test_event = {
    "logEvents": [
        {
            "message": "ERROR: Test error message"
        }
    ]
}

response = lambda_client.invoke(
    FunctionName='feedbackhub-production-bedrock-log-summarizer',
    Payload=json.dumps(test_event)
)

print(json.loads(response['Payload'].read()))
```

## Benefits

1. **Testing Flexibility**: Can test summarization without live errors
2. **Demo Capability**: Easy to demonstrate functionality with controlled data
3. **Development Support**: Faster iteration during development
4. **Backward Compatibility**: No breaking changes to existing CloudWatch integration

## Monitoring

- Manual events are logged with `logStreamName: 'manual-test'`
- All processing is logged to CloudWatch for debugging
- S3 summaries include source identification
- Error handling maintains function stability

## Security Considerations

- Manual events are processed the same way as CloudWatch events
- No additional IAM permissions required
- Timestamps are validated and sanitized
- Message content is processed through existing Bedrock pipeline 