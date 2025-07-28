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
  
  // Base configuration
  const clusterHost = 'cluster0.is0hvmh.mongodb.net'
  const password = process.env.MONGODB_PASSWORD
  if (!password) {
    throw new Error('MONGODB_PASSWORD environment variable is required')
  }
  const retryWrites = 'true'
  const writeConcern = 'majority'
  const appName = 'Cluster0'
  
  // Environment-specific configuration
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
  
  // Construct MongoDB URI
  const mongoUri = `mongodb+srv://${config.username}:${password}@${clusterHost}/${config.database}?retryWrites=${retryWrites}&w=${writeConcern}&appName=${appName}`
  
  return {
    uri: mongoUri,
    database: config.database,
    username: config.username,
    environment: config.environment
  }
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
    client = new MongoClient(config.uri, connectionOptions)
    globalWithMongo._mongoClientPromise = client.connect()
      .then(client => {
        console.log(`✅ Connected to MongoDB Atlas as '${config.username}' user`)
        console.log(`📊 Database: ${config.database}`)
        console.log(`🌍 Environment: ${config.environment}`)
        console.log(`🔗 Cluster: ${config.uri.split('@')[1].split('/')[0]}`)
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
  clientPromise = globalWithMongo._mongoClientPromise
} else {
  // In production mode, it's best to not use a global variable.
  const config = getCurrentMongoConfig()
  client = new MongoClient(config.uri, connectionOptions)
  clientPromise = client.connect()
    .then(client => {
      console.log(`✅ Connected to MongoDB Atlas as '${config.username}' user`)
      console.log(`📊 Database: ${config.database}`)
      console.log(`🌍 Environment: ${config.environment}`)
      console.log(`🔗 Cluster: ${config.uri.split('@')[1].split('/')[0]}`)
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

// Export a module-scoped MongoClient promise. By doing this in a
// separate module, the client can be shared across functions.
export default clientPromise

export async function getDb(): Promise<Db> {
  try {
    const client = await clientPromise
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

 