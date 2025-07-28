#!/usr/bin/env node

// Simple test script to verify MongoDB environment detection
const { getCurrentMongoConfig } = require('./app/lib/mongodb.ts');

console.log('🧪 Testing MongoDB Environment Detection');
console.log('=====================================');

// Test development environment
process.env.NODE_ENV = 'development';
const devConfig = getCurrentMongoConfig();
console.log('\n📊 Development Environment:');
console.log(`   Environment: ${devConfig.environment}`);
console.log(`   User: ${devConfig.username}`);
console.log(`   Database: ${devConfig.database}`);

// Test production environment
process.env.NODE_ENV = 'production';
const prodConfig = getCurrentMongoConfig();
console.log('\n📊 Production Environment:');
console.log(`   Environment: ${prodConfig.environment}`);
console.log(`   User: ${prodConfig.username}`);
console.log(`   Database: ${prodConfig.database}`);

// Test with no NODE_ENV
delete process.env.NODE_ENV;
const defaultConfig = getCurrentMongoConfig();
console.log('\n📊 Default Environment (no NODE_ENV):');
console.log(`   Environment: ${defaultConfig.environment}`);
console.log(`   User: ${defaultConfig.username}`);
console.log(`   Database: ${defaultConfig.database}`);

console.log('\n✅ Environment detection test completed!'); 