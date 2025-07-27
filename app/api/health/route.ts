import { NextResponse } from 'next/server'
import { getDb } from '../../lib/mongodb'

export async function GET() {
  try {
    // Check MongoDB connection
    const db = await getDb()
    await db.admin().ping()
    
    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'feedbackhub',
      version: '1.0.0',
      database: 'connected'
    })
  } catch (error) {
    console.error('Health check failed:', error)
    return NextResponse.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        service: 'feedbackhub',
        version: '1.0.0',
        database: 'disconnected',
        error: 'Database connection failed'
      },
      { status: 503 }
    )
  }
} 