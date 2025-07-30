/** @type {import('next').NextConfig} */
const nextConfig = {
  // Use standalone output for production Docker
  ...(process.env.NODE_ENV === 'production' && { output: 'standalone' }),
  
  // Disable SWC to avoid binary issues in Docker
  swcMinify: false,
  experimental: {
    forceSwcTransforms: false,
  },
  
  // Configure for Docker development
  webpack: (config, { dev, isServer }) => {
    // Optimize for development
    if (dev) {
      config.watchOptions = {
        poll: 1000,
        aggregateTimeout: 300,
      }
    }
    return config
  },
  
  // Internal rewrites for Green environment
  async rewrites() {
    return [
      {
        source: '/green',
        destination: '/', // Handle /green without trailing slash
      },
      {
        source: '/green/',
        destination: '/', // Handle /green/ with trailing slash
      },
      {
        source: '/green/:path*',
        destination: '/:path*', // Handle /green/anything
      },
    ];
  },
  
  // Disable automatic trailing slash redirects
  trailingSlash: false,
  
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig 