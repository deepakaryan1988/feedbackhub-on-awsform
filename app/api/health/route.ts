import { NextResponse } from 'next/server'
import { getDb, mongoConfig } from '../../lib/mongodb'

export async function GET() {
  try {
    const config = mongoConfig()
    
    // Handle build-time scenario
    if (config.strategy === 'build-time-mock') {
      return NextResponse.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'feedbackhub',
        version: '1.0.0',
        database: {
          status: 'build-time',
          environment: config.environment,
          database: config.database,
          user: config.username,
          cluster: 'build-time'
        }
      })
    }
    
    // Check MongoDB connection
    const db = await getDb()
    await db.admin().ping()
    
    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'feedbackhub',
      version: '1.0.0',
      database: {
        status: 'connected',
        environment: config.environment,
        database: config.database,
        user: config.username,
        cluster: config.uri.split('@')[1]?.split('/')[0] || 'unknown'
      }
    })
  } catch (error) {
    console.error('Health check failed:', error)
    const config = mongoConfig()
    return NextResponse.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        service: 'feedbackhub',
        version: '1.0.0',
        database: {
          status: 'disconnected',
          environment: config.environment,
          database: config.database,
          user: config.username,
          cluster: config.uri.split('@')[1]?.split('/')[0] || 'unknown',
          error: error instanceof Error ? error.message : 'Database connection failed'
        }
      },
      { status: 503 }
    )
  }
} 