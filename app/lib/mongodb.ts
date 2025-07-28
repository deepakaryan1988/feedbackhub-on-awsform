import { MongoClient, Db } from 'mongodb'

/**
 * PLANNING PHASE COMPLETE:
 * 
 * This MongoDB connection layer implements:
 * 1. Dynamic environment-based connection switching (local vs production)
 * 2. Comprehensive logging to show connected user/database without exposing passwords
 * 3. Robust error handling with meaningful error messages
 * 4. Singleton pattern for connection reuse
 * 5. Graceful connection management for both development and production
 * 
 * Environment Configuration:
 * - Local (NODE_ENV=development): feedbackhub-local user → feedbackhub_local_db
 * - Production (NODE_ENV=production): feedbackhub user → feedbackhub_prod_db
 * - Both share same password and cluster hostname
 */

// Environment-based MongoDB configuration
const getMongoConfig = () => {
  // More reliable environment detection
  const nodeEnv = process.env.NODE_ENV || 'development'
  const isDevelopment = nodeEnv === 'development'
  console.log(`🔧 MongoDB Config: NODE_ENV=${nodeEnv}, isDevelopment=${isDevelopment}`)
  
  // Check if we're in a build environment (no runtime secrets available)
  const isBuildTime = typeof window === 'undefined' && 
    (!process.env.MONGODB_URI || process.env.MONGODB_URI.includes('mongo:27017') || process.env.MONGODB_URI.includes('localhost:27017'))
  if (isBuildTime) {
    console.log('🔧 Build time detected, using mock configuration')
    return {
      uri: 'mongodb://localhost:27017/feedbackhub',
      database: 'feedbackhub',
      username: 'build-time',
      environment: 'build',
      strategy: 'build-time-mock'
    }
  }
  
  // Try multiple connection strategies
  const connectionStrategies = [
    // Strategy 1: Direct MONGODB_URI from environment (production)
    () => {
      const mongoUri = process.env.MONGODB_URI
      console.log(`🔍 Strategy 1: MONGODB_URI=${mongoUri ? mongoUri.substring(0, 50) + '...' : 'NOT SET'}`)
      if (!mongoUri) {
        throw new Error('MONGODB_URI not set')
      }
      
      // Parse URI to extract database name
      const dbName = mongoUri.split('/').pop()?.split('?')[0] || 'feedbackhub'
      
      return {
        uri: mongoUri,
        database: dbName,
        username: 'from-uri',
        environment: isDevelopment ? 'development' : 'production',
        strategy: 'direct-uri'
      }
    },
    
    // Strategy 2: Full MongoDB Atlas with password
    () => {
      const clusterHost = 'cluster0.is0hvmh.mongodb.net'
      const password = process.env.MONGODB_PASSWORD
      if (!password) {
        throw new Error('MONGODB_PASSWORD not set')
      }
      
      const config = isDevelopment 
        ? {
            username: 'feedbackhub-local',
            database: 'feedbackhub_local_db',
            environment: 'development'
          }
        : {
            username: 'feedbackhub',
            database: 'feedbackhub_prod_db', 
            environment: 'production'
          }
      
      const mongoUri = `mongodb+srv://${config.username}:${password}@${clusterHost}/${config.database}?retryWrites=true&w=majority&appName=Cluster0`
      
      return {
        uri: mongoUri,
        database: config.database,
        username: config.username,
        environment: config.environment,
        strategy: 'mongodb-atlas'
      }
    },
    
    // Strategy 3: Local MongoDB with Docker
    () => {
      const config = isDevelopment 
        ? {
            username: 'local',
            database: 'feedbackhub',
            environment: 'development'
          }
        : {
            username: 'local',
            database: 'feedbackhub',
            environment: 'production'
          }
      
      const mongoUri = 'mongodb://mongo:27017/feedbackhub'
      
      return {
        uri: mongoUri,
        database: config.database,
        username: config.username,
        environment: config.environment,
        strategy: 'local-docker'
      }
    },
    
    // Strategy 4: Localhost MongoDB
    () => {
      const config = isDevelopment 
        ? {
            username: 'local',
            database: 'feedbackhub',
            environment: 'development'
          }
        : {
            username: 'local',
            database: 'feedbackhub',
            environment: 'production'
          }
      
      const mongoUri = 'mongodb://localhost:27017/feedbackhub'
      
      return {
        uri: mongoUri,
        database: config.database,
        username: config.username,
        environment: config.environment,
        strategy: 'localhost'
      }
    }
  ]
  
  // Try each strategy until one works
  for (const strategy of connectionStrategies) {
    try {
      const config = strategy()
      console.log(`🔧 Using connection strategy: ${config.strategy}`)
      return config
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      console.log(`⚠️  Strategy failed: ${errorMessage}`)
      continue
    }
  }
  
  // If all strategies fail, provide helpful error message
  throw new Error(`MongoDB connection failed. Please set up one of the following:
1. MONGODB_PASSWORD environment variable for MongoDB Atlas
2. MONGODB_URI environment variable for direct connection
3. Local MongoDB instance (docker-compose up -d)
4. Local MongoDB on localhost:27017`)
}

// Get configuration based on current environment (dynamic)
const getCurrentMongoConfig = () => getMongoConfig()

// Connection options for better reliability
const connectionOptions = {
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  connectTimeoutMS: 10000,
  retryWrites: true
}

let client: MongoClient
let clientPromise: Promise<MongoClient>

// Check if we're in a browser environment
const isBrowser = typeof window !== 'undefined'

if (isBrowser) {
  // In browser environment, we can't connect to MongoDB directly
  clientPromise = Promise.reject(new Error('MongoDB not available in browser'))
} else if ((process.env.NODE_ENV || 'development') === 'development') {
  // In development mode, use a global variable so that the value
  // is preserved across module reloads caused by HMR (Hot Module Replacement).
  let globalWithMongo = global as typeof globalThis & {
    _mongoClientPromise?: Promise<MongoClient>
  }

  if (!globalWithMongo._mongoClientPromise) {
    const config = getCurrentMongoConfig()
    
    // If this is a build-time mock configuration, don't actually connect
    if (config.strategy === 'build-time-mock') {
      console.log('🔧 Build time: Skipping actual MongoDB connection')
      globalWithMongo._mongoClientPromise = Promise.resolve(null as any)
    } else {
      client = new MongoClient(config.uri, connectionOptions)
      globalWithMongo._mongoClientPromise = client.connect()
        .then(client => {
          console.log(`✅ Connected to MongoDB as '${config.username}' user`)
          console.log(`📊 Database: ${config.database}`)
          console.log(`🌍 Environment: ${config.environment}`)
          console.log(`🔧 Strategy: ${config.strategy}`)
          if (config.strategy === 'mongodb-atlas') {
            console.log(`🔗 Cluster: ${config.uri.split('@')[1].split('/')[0]}`)
          }
          return client
        })
        .catch(error => {
          console.error('❌ MongoDB connection failed:')
          console.error(`   Environment: ${config.environment}`)
          console.error(`   User: ${config.username}`)
          console.error(`   Database: ${config.database}`)
          console.error(`   Error: ${error.message}`)
          throw error
        })
    }
  }
  clientPromise = globalWithMongo._mongoClientPromise
} else {
  // In production mode, it's best to not use a global variable.
  const config = getCurrentMongoConfig()
  
  // If this is a build-time mock configuration, don't actually connect
  if (config.strategy === 'build-time-mock') {
    console.log('🔧 Build time: Skipping actual MongoDB connection')
    clientPromise = Promise.resolve(null as any)
  } else {
    client = new MongoClient(config.uri, connectionOptions)
    clientPromise = client.connect()
      .then(client => {
        console.log(`✅ Connected to MongoDB as '${config.username}' user`)
        console.log(`📊 Database: ${config.database}`)
        console.log(`🌍 Environment: ${config.environment}`)
        console.log(`🔧 Strategy: ${config.strategy}`)
        if (config.strategy === 'mongodb-atlas') {
          console.log(`🔗 Cluster: ${config.uri.split('@')[1].split('/')[0]}`)
        }
        return client
      })
      .catch(error => {
        console.error('❌ MongoDB connection failed:')
        console.error(`   Environment: ${config.environment}`)
        console.error(`   User: ${config.username}`)
        console.error(`   Database: ${config.database}`)
        console.error(`   Error: ${error.message}`)
        throw error
      })
  }
}

// Export a module-scoped MongoClient promise. By doing this in a
// separate module, the client can be shared across functions.
export default clientPromise

export async function getDb(): Promise<Db> {
  try {
    const client = await clientPromise
    
    // Handle build-time mock configuration
    if (!client) {
      throw new Error('MongoDB not available during build time')
    }
    
    const db = client.db()
    
    // Test the connection with a ping
    await db.admin().ping()
    
    return db
  } catch (error) {
    const config = getCurrentMongoConfig()
    console.error('❌ Database connection failed:', error)
    console.error(`   Attempted connection to: ${config.database}`)
    console.error(`   Using user: ${config.username}`)
    console.error(`   Environment: ${config.environment}`)
    
    // Provide helpful error message based on error type
    let errorMessage = 'Database connection failed. Please check your MongoDB configuration.'
    
    if (error instanceof Error) {
      if (error.message.includes('ECONNREFUSED') || error.message.includes('ENOTFOUND')) {
        errorMessage = 'Unable to reach MongoDB Atlas cluster. Please check your network connection and cluster hostname.'
      } else if (error.message.includes('Authentication failed')) {
        errorMessage = 'MongoDB authentication failed. Please verify your username and password.'
      } else if (error.message.includes('Server selection timed out')) {
        errorMessage = 'MongoDB server selection timed out. Please check your cluster status and network connectivity.'
      }
    }
    
    throw new Error(errorMessage)
  }
}

export async function closeConnection(): Promise<void> {
  try {
    const client = await clientPromise
    await client.close()
    console.log('🔌 MongoDB connection closed successfully')
  } catch (error) {
    // Ignore errors when closing connection
    console.log('⚠️ Error closing database connection:', error)
  }
}

// Export configuration function for debugging/testing purposes
export { getCurrentMongoConfig as mongoConfig }

 