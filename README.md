# FeedbackHub – AWS ECS Fargate Deployment

A production-ready feedback system built with Next.js 14, designed for deployment on AWS ECS Fargate. This application provides a simple yet powerful platform for collecting and displaying user feedback with MongoDB integration.

## 🚀 Features

- **Modern Tech Stack**: Built with Next.js 14, TypeScript, and Tailwind CSS
- **MongoDB Integration**: Persistent storage with MongoDB Atlas or self-hosted MongoDB
- **Responsive Design**: Clean, modern UI that works on all devices
- **Production Ready**: Optimized for AWS ECS Fargate deployment
- **Containerized**: Docker support with multi-stage builds
- **Type Safe**: Full TypeScript support throughout the application

## 📋 Prerequisites

- Node.js 20+ 
- npm or yarn
- Docker (for containerized deployment)
- MongoDB database (Atlas or self-hosted)

## 🛠️ Local Development

### 1. Clone the Repository

```bash
git clone git@github.com:deepakaryan1988/feedbackhub-on-awsform.git
cd feedbackhub-on-awsform
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Setup

Create a `.env.local` file in the root directory:

```bash
# MongoDB Connection String
MONGODB_URI=mongodb://localhost:27017/feedbackhub
# or for MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/feedbackhub

# Optional: Custom port (defaults to 3000)
PORT=3000
```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

### 5. Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript type checking

## 🐳 Docker Deployment

### Build the Docker Image

```bash
docker build -t feedbackhub .
```

### Run the Container

```bash
docker run -p 3000:3000 \
  -e MONGODB_URI="your-mongodb-connection-string" \
  -e PORT=3000 \
  feedbackhub
```

### Docker Compose (Optional)

Create a `docker-compose.yml` file for local development:

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - MONGODB_URI=mongodb://mongo:27017/feedbackhub
      - NODE_ENV=production
    depends_on:
      - mongo
  
  mongo:
    image: mongo:latest
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

Run with:
```bash
docker-compose up -d
```

## ☁️ AWS ECS Fargate Deployment

This application is designed for deployment on AWS ECS Fargate. The Docker image is optimized for:

- **Multi-stage builds** for smaller production images
- **Non-root user** for security
- **Health checks** and proper logging
- **Environment variable** configuration
- **Port 3000** exposure (configurable via `PORT` env var)

### Environment Variables for ECS

- `MONGODB_URI` - MongoDB connection string (required)
- `PORT` - Application port (defaults to 3000)
- `NODE_ENV` - Environment (set to 'production')

### Infrastructure

Terraform-based AWS infrastructure is under construction and will include:
- ECS Fargate cluster
- Application Load Balancer
- RDS or DocumentDB for MongoDB
- CloudWatch logging
- Auto-scaling policies

## 📁 Project Structure

```
feedbackhub-on-awsform/
├── app/                    # Next.js 14 app directory
│   ├── api/               # API routes
│   ├── globals.css        # Global styles
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Homepage
├── components/            # React components
│   ├── FeedbackForm.tsx   # Feedback submission form
│   └── FeedbackList.tsx   # Feedback display component
├── lib/                   # Utility libraries
│   └── mongodb.ts         # MongoDB connection utility
├── types/                 # TypeScript type definitions
│   └── feedback.ts        # Feedback-related types
├── Dockerfile             # Production Docker configuration
├── .dockerignore          # Docker build exclusions
├── .gitignore             # Git exclusions
├── next.config.js         # Next.js configuration
├── package.json           # Dependencies and scripts
├── tailwind.config.js     # Tailwind CSS configuration
└── tsconfig.json          # TypeScript configuration
```

## 🔧 API Endpoints

### GET /api/feedback
Retrieves all feedback entries (limited to 50 most recent)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "message": "Great application!",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### POST /api/feedback
Creates a new feedback entry

**Request Body:**
```json
{
  "name": "John Doe",
  "message": "Great application!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "message": "Great application!",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

## 🛡️ Security Considerations

- All environment variables are properly handled
- No hardcoded secrets or credentials
- Input validation on API endpoints
- CORS headers configured
- XSS protection enabled
- Content-Type validation

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team

---

**Built with ❤️ for AWS ECS Fargate deployment**