# FeedbackHub – AWS ECS Fargate Deployment

A production-ready feedback system built with Next.js 14, designed for deployment on AWS ECS Fargate. This application provides a simple yet powerful platform for collecting and displaying user feedback with MongoDB integration.

## 🚀 Features

- **Modern Tech Stack**: Built with Next.js 14, TypeScript, and Tailwind CSS
- **MongoDB Integration**: Persistent storage with MongoDB Atlas or self-hosted MongoDB
- **Responsive Design**: Clean, modern UI that works on all devices
- **Production Ready**: Optimized for AWS ECS Fargate deployment
- **Containerized**: Docker support with multi-stage builds
- **Type Safe**: Full TypeScript support throughout the application
- **Infrastructure as Code**: Terraform-based AWS infrastructure
- **DevOps Ready**: Modular structure for team collaboration

## 📋 Prerequisites

- Node.js 20+ 
- npm or yarn
- Docker (for containerized deployment)
- AWS CLI (for infrastructure deployment)
- Terraform (for infrastructure management)
- MongoDB database (Atlas or self-hosted)

## 🏗️ Project Structure

This project follows industry-standard practices with a modular, DevOps-ready structure:

```
.
├── app/                     # Next.js application code
│   ├── api/                 # API routes
│   ├── components/          # React components
│   ├── lib/                 # Utility libraries
│   ├── types/               # TypeScript type definitions
│   ├── globals.css          # Global styles
│   ├── layout.tsx           # Root layout
│   └── page.tsx             # Home page
│
├── docker/                  # Docker-related files
│   ├── Dockerfile           # Multi-stage Docker build
│   ├── docker-compose.yml   # Local development setup
│   ├── mongo-init.js        # MongoDB initialization script
│   └── .dockerignore        # Docker ignore file
│
├── infra/                   # Terraform composition and scripts
│   ├── *.tf                 # Main Terraform files
│   ├── *.tfvars*            # Terraform variables
│   ├── deploy.sh            # Deployment script
│   ├── build-and-push.sh    # Docker build and push script
│   └── get-vpc-info.sh      # VPC information script
│
├── terraform/               # Modular Terraform components
│   ├── alb/                 # Application Load Balancer
│   ├── cloudwatch/          # CloudWatch logs and monitoring
│   ├── ecs/                 # ECS cluster and service
│   └── secrets/             # AWS Secrets Manager
│
├── scripts/                 # Helper and CI/CD scripts
│   └── build.sh             # Build script
│
├── docs/                    # Documentation
│   ├── structure.md         # Project structure guide
│   ├── infra-overview.md    # Infrastructure overview
│   ├── deployment.md        # Deployment guide
│   └── env-setup.md         # Environment setup guide
│
├── .gitignore               # Git ignore rules
├── env.example              # Environment variables example
├── README.md                # Project README
├── tailwind.config.js       # Tailwind CSS configuration
├── postcss.config.js        # PostCSS configuration
├── tsconfig.json            # TypeScript configuration
├── package.json             # Node.js dependencies
└── package-lock.json        # Locked dependencies
```

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
# Using Node.js directly
npm run dev

# Using Docker Compose (recommended for full-stack testing)
cd docker/
docker-compose up -d
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
cd docker/
docker build -t feedbackhub ..
```

### Run the Container

```bash
docker run -p 3000:3000 \
  -e MONGODB_URI="your-mongodb-connection-string" \
  -e PORT=3000 \
  feedbackhub
```

### Docker Compose

The project includes a `docker-compose.yml` file for local development:

```bash
cd docker/
docker-compose up -d
```

This will start both the application and a local MongoDB instance.

## ☁️ AWS ECS Fargate Deployment

This application is designed for deployment on AWS ECS Fargate with a complete infrastructure-as-code approach.

### Quick Start

1. **Deploy Infrastructure**:
   ```bash
   cd infra/
   terraform init
   terraform apply
   ```

2. **Build and Deploy Application**:
   ```bash
   ./build-and-push.sh
   ./deploy.sh
   ```

3. **Verify Deployment**:
   ```bash
   # Get ALB DNS name
   ALB_DNS=$(terraform output -raw alb_dns_name)
   curl http://$ALB_DNS/api/health
   ```

### Infrastructure Components

- **ECS Fargate Cluster**: Containerized application hosting
- **Application Load Balancer**: Traffic distribution and health checks
- **ECR Repository**: Docker image storage
- **CloudWatch Logs**: Application logging and monitoring
- **Secrets Manager**: Secure credential storage
- **IAM Roles**: Least-privilege access control

### Environment Variables for ECS

- `MONGODB_URI` - MongoDB connection string (from Secrets Manager)
- `PORT` - Application port (defaults to 3000)
- `NODE_ENV` - Environment (set to 'production')

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Project Structure](docs/structure.md)** - Detailed project organization
- **[Infrastructure Overview](docs/infra-overview.md)** - AWS architecture and components
- **[Deployment Guide](docs/deployment.md)** - Step-by-step deployment instructions
- **[Environment Setup](docs/env-setup.md)** - Development and production environment setup

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

### GET /api/health
Health check endpoint for load balancer and monitoring

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "feedbackhub",
  "version": "1.0.0",
  "database": "connected"
}
```

## 🛡️ Security Considerations

- All environment variables are properly handled
- No hardcoded secrets or credentials
- Input validation on API endpoints
- CORS headers configured
- XSS protection enabled
- Content-Type validation
- IAM roles with least privilege
- Secrets stored in AWS Secrets Manager
- VPC with private subnets for ECS tasks

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
- Check the documentation in the `docs/` directory

---

**Built with ❤️ for AWS ECS Fargate deployment with modern DevOps practices**