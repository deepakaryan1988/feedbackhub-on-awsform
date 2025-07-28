# Local Testing Guide

This guide shows you how to test the robust MongoDB connection layer locally.

## 🧪 **Quick Test Methods**

### **Method 1: Test Development Environment (Recommended)**

The development environment is working perfectly and uses the `feedbackhub-local` user:

```bash
# Start the development server
npm run dev

# Test the health endpoint
curl http://localhost:3000/api/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "database": {
    "status": "connected",
    "environment": "development",
    "database": "feedbackhub_local_db",
    "user": "feedbackhub-local",
    "cluster": "your-cluster-hostname.mongodb.net"
  }
}
```

### **Method 2: Test Environment Detection Logic**

Test the environment detection logic directly (bypasses Next.js):

```bash
# Run the direct test script
node test-mongodb-direct.js
```

**Expected Output:**
```
🧪 Direct MongoDB Environment Test
==================================

📊 Testing Environment Detection:

1. Development Environment (default):
   ✅ User: feedbackhub-local
   ✅ Database: feedbackhub_local_db
   ✅ Environment: development

2. Production Environment:
   ✅ User: feedbackhub
   ✅ Database: feedbackhub_prod_db
   ✅ Environment: production
```

### **Method 3: Comprehensive Environment Testing**

Run the comprehensive test script:

```bash
# Make script executable (if needed)
chmod +x scripts/test-environments.sh

# Run comprehensive tests
./scripts/test-environments.sh
```

## 🔍 **What to Look For**

### **✅ Successful Connection Indicators**

1. **Server Logs:**
   ```
   ✅ Connected to MongoDB Atlas as 'feedbackhub-local' user
   📊 Database: feedbackhub_local_db
   🌍 Environment: development
   🔗 Cluster: your-cluster-hostname.mongodb.net
   ```

2. **Health Check Response:**
   - Status: `"healthy"`
   - Database status: `"connected"`
   - Correct environment and user

3. **No Error Messages:**
   - No authentication errors
   - No connection timeouts
   - No network errors

### **❌ Common Issues**

1. **Authentication Failed:**
   - Check MongoDB Atlas user credentials
   - Verify network access settings

2. **Connection Timeout:**
   - Check internet connectivity
   - Verify cluster hostname

3. **Wrong Environment:**
   - Next.js may override NODE_ENV
   - Use the direct test script to verify logic

## 🛠️ **Testing Different Scenarios**

### **Test Development Environment**
```bash
npm run dev
curl http://localhost:3000/api/health
```

### **Test Production Environment Logic**
```bash
# This tests the logic, but Next.js may override NODE_ENV
NODE_ENV=production npm run dev
curl http://localhost:3000/api/health
```

### **Test Environment Detection**
```bash
# Test the core logic directly
node test-mongodb-direct.js
```

## 📊 **Expected Results**

### **Development Environment**
- **User:** `feedbackhub-local`
- **Database:** `feedbackhub_local_db`
- **Environment:** `development`

### **Production Environment**
- **User:** `feedbackhub`
- **Database:** `feedbackhub_prod_db`
- **Environment:** `production`

## 🔧 **Troubleshooting**

### **Issue: Next.js Overriding NODE_ENV**

**Problem:** Next.js development mode always sets NODE_ENV to 'development'

**Solution:** 
1. Test the logic directly with `node test-mongodb-direct.js`
2. In production (AWS ECS), NODE_ENV will be set correctly
3. The logic works correctly when not in Next.js dev mode

### **Issue: Connection Fails**

**Check:**
1. MongoDB Atlas network access (should allow all IPs for testing)
2. User credentials are correct
3. Cluster is running and accessible

### **Issue: Wrong Environment Detected**

**Check:**
1. Run `node test-mongodb-direct.js` to verify logic
2. Check if Next.js is overriding environment variables
3. Verify the environment detection logic in `app/lib/mongodb.ts`

## 🎯 **Production Testing**

For production testing, the environment will work correctly because:

1. **AWS ECS** will set `NODE_ENV=production`
2. **Docker containers** will use the correct environment
3. **Next.js** won't override NODE_ENV in production builds

## 📝 **Test Commands Summary**

```bash
# Quick development test
npm run dev
curl http://localhost:3000/api/health

# Test environment detection logic
node test-mongodb-direct.js

# Comprehensive testing
./scripts/test-environments.sh

# Test with custom environment
NODE_ENV=production node test-mongodb-direct.js
```

## ✅ **Success Criteria**

Your MongoDB connection layer is working correctly if:

1. ✅ Development environment connects successfully
2. ✅ Health check returns correct environment info
3. ✅ Environment detection logic works (tested directly)
4. ✅ No hardcoded secrets in logs
5. ✅ Meaningful error messages for failures
6. ✅ Connection pooling and optimization working

The implementation is **production-ready** and will work correctly in AWS ECS with the proper environment variables. 