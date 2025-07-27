# Project Structure

This document outlines the organization of the FeedbackHub project, which follows industry-standard practices for modern full-stack DevOps-ready applications.

## Directory Structure

```
.
├── app/                     # Next.js application code
│   ├── api/                 # API routes
│   │   ├── feedback/        # Feedback API endpoints
│   │   └── health/          # Health check endpoint
│   ├── components/          # React components
│   │   ├── BackgroundPattern.tsx
│   │   ├── FeedbackForm.tsx
│   │   ├── FeedbackList.tsx
│   │   ├── HeroSection.tsx
│   │   └── LoadingSpinner.tsx
│   ├── lib/                 # Utility libraries
│   │   ├── animations.ts    # Framer Motion animations
│   │   └── mongodb.ts       # MongoDB connection utilities
│   ├── types/               # TypeScript type definitions
│   │   └── feedback.ts      # Feedback-related types
│   ├── error.tsx            # Error boundary
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
│   ├── structure.md         # This file
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

## Key Design Principles

### 1. Separation of Concerns
- **App Code**: All Next.js application code is contained in the `app/` directory
- **Infrastructure**: Terraform configurations are separated into modular components
- **Docker**: All Docker-related files are in the `docker/` directory
- **Documentation**: Comprehensive documentation in the `docs/` directory

### 2. Modular Infrastructure
- **Terraform Modules**: Reusable infrastructure components in `terraform/`
- **Composition**: Main infrastructure orchestration in `infra/`
- **Scripts**: Deployment and utility scripts in `scripts/`

### 3. Type Safety
- **Path Aliases**: Configured in `tsconfig.json` for clean imports
- **Type Definitions**: Centralized in `app/types/`
- **Consistent Imports**: Using `@components/*`, `@lib/*`, `@types/*` aliases

### 4. DevOps Ready
- **Containerization**: Docker setup for consistent environments
- **Infrastructure as Code**: Terraform for reproducible deployments
- **CI/CD Ready**: Scripts and configurations for automation
- **Monitoring**: CloudWatch integration for observability

## Import Paths

The project uses TypeScript path aliases for clean imports:

```typescript
// Components
import FeedbackForm from '@components/FeedbackForm'
import FeedbackList from '@components/FeedbackList'

// Utilities
import { getDb } from '@lib/mongodb'
import { fadeInUp } from '@lib/animations'

// Types
import { Feedback } from '@types/feedback'
```

## Development Workflow

1. **Local Development**: Use `docker-compose.yml` for local setup
2. **Infrastructure**: Deploy with Terraform from `infra/` directory
3. **Application**: Build and deploy Docker image to ECS
4. **Monitoring**: Use CloudWatch for logs and metrics

This structure promotes maintainability, scalability, and team collaboration while following industry best practices. 