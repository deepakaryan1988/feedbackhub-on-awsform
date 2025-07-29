# Health Checks & Lessons Learned

## ECS Container Health Checks for Next.js

### The Challenge

When deploying Next.js applications on ECS Fargate, we encountered several challenges with health checks that are worth documenting for future reference.

### Lessons Learned

#### 1. Next.js Health Check Endpoint Design

**Problem**: Standard health checks were failing because Next.js API routes have specific requirements.

**Solution**: Created dedicated health check endpoints that:
- Return quickly (under 30 seconds)
- Don't require database connections for basic health
- Provide meaningful status information

```typescript
// /api/health/route.ts
export async function GET() {
  return Response.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  })
}
```

#### 2. ECS Task Definition Health Check Configuration

**Problem**: Default health check settings caused premature task termination.

**Solution**: Configured health checks with appropriate timeouts:

```json
{
  "healthCheck": {
    "command": ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"],
    "interval": 30,
    "timeout": 5,
    "retries": 3,
    "startPeriod": 60
  }
}
```

#### 3. Database Connection Health Checks

**Problem**: Health checks that require database connections can fail during database maintenance or network issues.

**Solution**: Implemented layered health checks:
- **Basic Health**: Application responds (no DB required)
- **Database Health**: Separate endpoint for DB connectivity
- **Graceful Degradation**: App continues to work even if DB is temporarily unavailable

#### 4. Container Startup Time

**Problem**: Next.js applications can take 30-60 seconds to start, causing health check failures.

**Solution**: 
- Increased `startPeriod` to 60 seconds
- Used lightweight health checks during startup
- Implemented progressive health check complexity

### Best Practices Implemented

1. **Separate Health Check Endpoints**:
   - `/api/health` - Basic application health
   - `/api/health/db` - Database connectivity
   - `/api/health/simple` - Minimal health check

2. **Appropriate Timeouts**:
   - Health check timeout: 5 seconds
   - Retry interval: 30 seconds
   - Start period: 60 seconds

3. **Graceful Error Handling**:
   - Health checks don't throw exceptions
   - Return appropriate HTTP status codes
   - Include meaningful error messages

4. **Monitoring Integration**:
   - Health check results logged to CloudWatch
   - Metrics for health check success/failure rates
   - Alerts for repeated failures

### Configuration Files

#### ECS Task Definition Health Check
```json
{
  "healthCheck": {
    "command": [
      "CMD-SHELL",
      "curl -f http://localhost:3000/api/health/simple || exit 1"
    ],
    "interval": 30,
    "timeout": 5,
    "retries": 3,
    "startPeriod": 60
  }
}
```

#### Application Load Balancer Health Check
```hcl
health_check {
  path                = "/api/health"
  port                = "traffic-port"
  healthy_threshold   = 2
  unhealthy_threshold = 3
  timeout             = 5
  interval            = 30
  matcher             = "200"
}
```

### Troubleshooting Health Check Issues

1. **Check Container Logs**:
   ```bash
   aws logs tail /ecs/feedbackhub --since 1h --follow
   ```

2. **Verify Health Check Endpoint**:
   ```bash
   curl -v http://your-alb-url/api/health
   ```

3. **Test Database Connection**:
   ```bash
   curl -v http://your-alb-url/api/health/db
   ```

4. **Check ECS Service Events**:
   ```bash
   aws ecs describe-services --cluster feedbackhub-production-cluster --services feedbackhub-service
   ```

### Key Takeaways

- **Start Simple**: Begin with basic health checks and add complexity gradually
- **Monitor Everything**: Log health check results and monitor patterns
- **Plan for Failures**: Design health checks that don't cause cascading failures
- **Test Thoroughly**: Test health checks in staging before production
- **Document Everything**: Keep detailed records of health check behavior and troubleshooting steps

This approach ensures reliable health monitoring while maintaining application stability and providing clear visibility into system health. 