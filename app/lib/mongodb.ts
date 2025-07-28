import { MongoClient, Db } from 'mongodb'

// Get MongoDB URI from environment variables
const mongoUri = process.env.MONGODB_URI || process.env.MONGO_URL || 'mongodb+srv://feedbackhub:Deepakaryan1988@cluster0.is0hvmh.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'

const uri = mongoUri
const options = {
  // Add connection options for better reliability
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
}

let client: MongoClient
let clientPromise: Promise<MongoClient>

// Check if we're in a browser environment
const isBrowser = typeof window !== 'undefined'

if (isBrowser) {
  // In browser environment, we can't connect to MongoDB directly
  clientPromise = Promise.reject(new Error('MongoDB not available in browser'))
} else if (process.env.NODE_ENV === 'development') {
  // In development mode, use a global variable so that the value
  // is preserved across module reloads caused by HMR (Hot Module Replacement).
  let globalWithMongo = global as typeof globalThis & {
    _mongoClientPromise?: Promise<MongoClient>
  }

  if (!globalWithMongo._mongoClientPromise) {
    client = new MongoClient(uri, options)
    globalWithMongo._mongoClientPromise = client.connect()
  }
  clientPromise = globalWithMongo._mongoClientPromise
} else {
  // In production mode, it's best to not use a global variable.
  client = new MongoClient(uri, options)
  clientPromise = client.connect()
}

// Export a module-scoped MongoClient promise. By doing this in a
// separate module, the client can be shared across functions.
export default clientPromise

export async function getDb(): Promise<Db> {
  try {
    const client = await clientPromise
    return client.db()
  } catch (error) {
    console.error('Database connection failed:', error)
    throw new Error('Database connection failed. Please check your MongoDB configuration.')
  }
}

export async function closeConnection(): Promise<void> {
  try {
    const client = await clientPromise
    await client.close()
  } catch (error) {
    // Ignore errors when closing connection
    console.log('Error closing database connection:', error)
  }
}

 