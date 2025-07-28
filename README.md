# FeedbackHub 🚀

A modern feedback collection app built with Next.js, MongoDB, and shadcn/ui.

## 🎯 Features

- ✅ Real-time feedback submission
- ✅ **Robust MongoDB connection layer** with environment-based configuration
- ✅ Modern UI with shadcn/ui components
- ✅ Toast notifications
- ✅ Responsive design
- ✅ Dark mode support
- ✅ **Health check endpoint** for monitoring
- ✅ **Comprehensive logging** without exposing sensitive data

## 🚀 Quick Start

### Option 1: Environment-Based MongoDB (Recommended)

The app now automatically configures MongoDB connections based on `NODE_ENV`:

- **Development** (`NODE_ENV=development`): Uses `feedbackhub-local` user → `feedbackhub_local_db`
- **Production** (`NODE_ENV=production`): Uses `feedbackhub` user → `DB_name`

1. **Start the app:**
   ```bash
   npm run dev  # Uses development environment
   ```

2. **Test the connection:**
   ```bash
   curl http://localhost:3000/api/health
   ```

3. **Open your browser:**
   ```
   http://localhost:3000
   ```

### Option 2: Docker Compose

1. **Development environment:**
   ```bash
   cd docker
   docker-compose -f docker-compose.dev.yml up --build
   ```

2. **Production environment:**
   ```bash
   cd docker
   docker-compose up --build
   ```

## 🛠️ Tech Stack

- **Frontend:** Next.js 14, React 18, TypeScript
- **Styling:** Tailwind CSS, shadcn/ui
- **Database:** MongoDB Atlas with robust connection layer
- **Icons:** Lucide React
- **Animations:** Framer Motion
- **Deployment:** Docker, ECS Fargate, Terraform

## 📁 Project Structure

```
feedbackhub-on-awsform/
├── app/                    # Next.js app directory
│   ├── api/               # API routes
│   │   ├── health/        # Health check endpoint
│   │   └── feedback/      # Feedback API
│   ├── components/        # React components
│   ├── lib/              # Utilities and database
│   │   └── mongodb.ts    # Robust MongoDB connection layer
│   └── types/            # TypeScript types
├── docker/               # Docker configuration
│   ├── docker-compose.yml      # Production setup
│   └── docker-compose.dev.yml  # Development setup
├── scripts/              # Utility scripts
│   └── test-mongodb-connection.sh
├── docs/                 # Documentation
│   └── mongodb-setup.md  # MongoDB connection documentation
└── components/           # UI components
```

## 🔧 Development

### Prerequisites
- Node.js 20+
- Docker (optional)
- npm or yarn

### Environment Variables

The app uses environment-based configuration. Create a `.env.local` file for custom overrides:

```env
# Optional: Override default MongoDB URI
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database?retryWrites=true&w=majority&appName=Cluster0

# Optional: Set custom port
PORT=3000

# Optional: Disable Next.js telemetry
NEXT_TELEMETRY_DISABLED=1
```

### Available Scripts
- `npm run dev` - Start development server (uses development environment)
- `npm run build` - Build for production
- `npm run start` - Start production server
- `./scripts/test-mongodb-connection.sh` - Test MongoDB connections

## 🧪 Testing

### Health Check Endpoint

Test the MongoDB connection:

```bash
curl http://localhost:3000/api/health
```

Expected response:
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

### Connection Testing

Test both environments:

```bash
# Test development environment
NODE_ENV=development npm run dev

# Test production environment  
NODE_ENV=production npm run dev

# Run comprehensive tests
./scripts/test-mongodb-connection.sh
```

## 🐳 Docker Commands

```bash
# Development environment
cd docker && docker-compose -f docker-compose.dev.yml up --build

# Production environment
cd docker && docker-compose up --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📝 API Endpoints

- `GET /api/health` - Health check with MongoDB status
- `GET /api/feedback` - Get all feedbacks
- `POST /api/feedback` - Submit new feedback

## 🎨 UI Components

Built with shadcn/ui:
- Button, Input, Textarea
- Card, Badge
- Toast notifications
- Loading states

## 🔄 Database Schema

```typescript
interface Feedback {
  _id?: string
  name: string
  message: string
  createdAt: Date
}
```

## 🚀 Deployment

The app is ready for deployment to:
- **AWS ECS Fargate** (recommended)
- Vercel
- Netlify
- Any Node.js hosting platform

### AWS Deployment

The app includes:
- **Terraform infrastructure** for ECS Fargate
- **Docker containerization** with multi-stage builds
- **AWS Secrets Manager** integration for production credentials
- **Environment-based configuration** for different deployment stages

## 📚 Documentation

- [MongoDB Setup Guide](docs/mongodb-setup.md) - Comprehensive MongoDB connection documentation
- [Environment Setup](docs/env-setup.md) - Environment configuration guide
- [Deployment Guide](docs/deployment.md) - AWS deployment instructions
- [Project Structure](docs/structure.md) - Detailed project organization

## 📄 License

MIT License