import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Handle /green/* paths by rewriting them internally
  if (pathname.startsWith('/green')) {
    // Create a new URL with the /green prefix removed
    const newUrl = new URL(request.url)
    
    // Handle exact matches for root paths
    if (pathname === '/green' || pathname === '/green/') {
      newUrl.pathname = '/'
    } else {
      // Handle other /green/* paths
      newUrl.pathname = pathname.replace(/^\/green\/?/, '/')
    }
    
    // Return a rewrite response (not a redirect)
    return NextResponse.rewrite(newUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
} 