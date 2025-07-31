![CI/CD](https://github.com/deepakaryan1988/feedbackhub-on-awsform/actions/workflows/deploy.yml/badge.svg)

# FeedbackHub-on-AWSform

> 💼 **Recruiter Note:** This project is a production-grade DevOps showcase integrating Terraform, ECS Fargate, AI (Bedrock Claude), Lambda, and CI/CD. It demonstrates my ability to design and deploy modern cloud architectures, optimize operations, and implement AI-powered observability pipelines.

> **FeedbackHub is a production-ready, cloud-native feedback microservice. Built to teach (and learn) modern, secure, cloud DevOps from code to dashboards.**

**FeedbackHub** is a fullstack Next.js app using MongoDB Atlas. It supports both:
- 🧪 Local development (connects directly to MongoDB Atlas via `feedbackhub‑local` user)
- ☁️ AWS production deployment on ECS (via `feedbackhub` user), with Terraform and AWS Secrets Manager

## 🏗️ Architecture

📊 **[View Architecture Diagram](docs/architecture.md)** - Complete system overview with Mermaid diagram

---

## 🚀 Phase 3: AWS Bedrock Log Summarizer Integration

FeedbackHub now integrates **AWS Bedrock (Claude model)** to automatically summarize ECS logs and store summaries in S3 for quick debugging and analytics.

**Architecture:**
- ECS Logs → CloudWatch → Lambda Trigger
- Lambda calls AWS Bedrock → Generates summary
- Summary stored in S3 (`feedbackhub-log-summaries` bucket)

**Proof of Implementation:**
Screenshots from AWS Console and CLI confirming successful integration:

![AWS Bedrock Successfully Integrated](docs/screenshots/AWS-Bedrock-successfully-integrated.png)
![AWS Bedrock Web Proof](docs/screenshots/AWS-Bedrock-web-proof.png)

**Interview Prep Highlights:**
- Demonstrates AI-powered observability to reduce MTTR
- Shows serverless + Bedrock integration with ECS Fargate
- Fully managed via Terraform for scalability

---

## 🏗️ System Architecture

```mermaid
graph TD
    subgraph "Frontend"
        UI[Next.js UI]
    end
    
    subgraph "Backend"
        API[Next.js API Routes]
        DB[(MongoDB Atlas)]
    end
    
    subgraph "AWS Infrastructure"
        ALB[Application Load Balancer]
        ECS[ECS Fargate Cluster]
        CW[CloudWatch Logs]
        LAMBDA[Lambda Bedrock Summarizer]
        BEDROCK[AWS Bedrock Claude]
        S3[S3 Summary Storage]
        SECRETS[AWS Secrets Manager]
    end
    
    subgraph "CI/CD"
        GH[GitHub Actions]
        ECR[ECR Repository]
    end
    
    UI --> ALB
    ALB --> ECS
    ECS --> API
    API --> DB
    ECS --> CW
    CW --> LAMBDA
    LAMBDA --> BEDROCK
    BEDROCK --> LAMBDA
    LAMBDA --> S3
    ECS --> SECRETS
    GH --> ECR
    ECR --> ECS
```

**Key Components:**
- **ECS Fargate**: Serverless container orchestration
- **AWS Bedrock**: AI-powered log summarization
- **Lambda**: Serverless event processing
- **Terraform**: Infrastructure as Code
- **GitHub Actions**: Automated CI/CD pipeline

---

## 🚀 Local Setup

```bash
git clone https://github.com/deepakaryan1988/feedbackhub-on-awsform.git
cd feedbackhub-on-awsform
cp .env.example .env.local
# Edit .env.local with your Atlas credentials if needed
npm install
npm run dev  # runs on http://localhost:3000
```

### ⚙️ Environment Variables

| File           | Purpose                        | Usage                        |
|----------------|-------------------------------|------------------------------|
| .env.local     | Local MongoDB Atlas connection| Used for NODE_ENV=development|
| .env.production| Atlas Prod URI (in AWS Secrets Manager) | Not committed         |
| .env.example   | Template for contributors      | Commit this only             |

---

## ☁️ Deploy to AWS ECS using Terraform

```bash
cd infra/
terraform init
terraform plan
terraform apply -auto-approve
```

- Ensure AWS Secrets Manager contains:
  ```
  MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-url>/DB_name?retryWrites=true&w=majority&appName=Cluster0
  ```
- Terraform will configure ECS Task Definition to fetch this secret securely.

---

## ✅ Validation & Health Checks

- **DNS:** Visit the ECS service / Load Balancer URL in browser
- **Health check endpoint:**
  ```bash
  GET /api/health
  # should return status 200 if DB is connected
  ```
- **Logs:**
  ```bash
  aws logs tail /ecs/feedbackhub --since 1h --follow --region ap-south-1 --no-cli-pager
  ```
  Look for:
  - `Connected to MongoDB as feedbackhub`
  - No authentication or DNS errors

---

## 🛡 Security Considerations

- `.env`, `.env.local`, `.env.production` are in `.gitignore`
- Only `.env.example` is committed
- AWS Secrets Manager used for production secrets
- **No credentials or passwords should ever be committed**

---

## 🧰 Troubleshooting

| Issue                        | Solution                                      |
|------------------------------|-----------------------------------------------|
| UI outdated in production    | Force ECS redeploy or verify image version    |
| Feedbacks not showing        | Check CloudWatch logs for MongoDB errors      |
| Form submission fails        | Verify API route logs for runtime/validation  |

---

## 🎯 What's Next (Roadmap)

### 🚀 Planned Features
- **ECS Blue/Green Deployment**: Zero-downtime deployments with automatic rollback
- **S3 Pre-signed Upload Support**: Direct file uploads to S3 with security
- **Observability Dashboard**: Centralized monitoring with CloudWatch dashboards
- **Multi-region Deployment**: Global distribution for better performance
- **API Rate Limiting**: Protect against abuse with intelligent throttling

### 🔧 Infrastructure Improvements
- **Auto-scaling Policies**: Dynamic scaling based on CPU/memory usage
- **CDN Integration**: CloudFront for static asset delivery
- **Database Read Replicas**: Improved read performance
- **Backup & Recovery**: Automated database backups and disaster recovery

### 📊 Monitoring & Analytics
- **Custom Metrics**: Application-specific CloudWatch metrics
- **Alerting**: Proactive notifications for issues
- **Performance Monitoring**: Response time and throughput tracking
- **User Analytics**: Usage patterns and feedback insights

---

## 💡 Lessons Learned

### Real-world DevOps Challenges

**Handling ECS container health checks for Next.js required customizing the pipeline and task definition. See [Health Check Documentation](docs/health.md) for detailed lessons learned.**

Key insights from production deployment:
- **Health Check Design**: Next.js apps need specialized health check endpoints
- **Startup Time Management**: Container health checks must account for Next.js startup delays
- **Database Resilience**: Health checks should gracefully handle temporary DB outages
- **Monitoring Integration**: Comprehensive logging and metrics are essential for troubleshooting

### Production Hardening
- **Security**: Implemented least-privilege IAM roles and network security
- **Reliability**: Multiple health check layers and graceful degradation
- **Observability**: Centralized logging with CloudWatch and structured error handling
- **Scalability**: Designed for horizontal scaling with load balancer integration

---

## 🧑‍💻 Contributing

- Fork the repo
- Work on a feature branch
- Copy `.env.example` and configure `.env.local`
- Submit a PR with meaningful tests if applicable

---

## 📄 License

MIT License

---

## 👤 About the Author

[**Deepak Kumar**](https://github.com/deepakaryan1988)

- 🔧 14+ years of experience in full-stack web development, specializing in **Drupal architecture**
- ☁️ Currently transitioning to **DevOps & AWS Cloud Engineering**
- 🧪 Building real-world DevOps projects using:
  - Terraform, Docker, ECS Fargate, ECR
  - GitHub Actions, CloudWatch, RDS, Secrets Manager
- 🧠 Lifelong learner, exploring the intersection of open-source, DevOps, and AI-driven automation

### 🏗️ Featured Projects
🚢 [**Drupal on AWS with ECS & EFS**](https://github.com/deepakaryan1988/Drupal-AWS)  
➡️ A complete infrastructure-as-code deployment of Drupal 11 using Terraform, Docker, ECS Fargate, RDS, and EFS.

🧱 [**Appwrite on AWS**](https://github.com/deepakaryan1988/appwrite-on-aws)  
➡️ Backend-as-a-service (BaaS) platform deployed on AWS using ECS Fargate + CI/CD + Secrets Manager + Redis + PostgreSQL.

📝 [**FeedbackHub on AWS**](https://github.com/deepakaryan1988/feedbackhub-on-awsform) *(CI/CD Ready)*  
➡️ Full-stack microservice-ready feedback platform built using Next.js, MongoDB, and AWS DevOps best practices with automated deployment pipeline.


### 🎯 Currently Learning
- 📦 AWS Lambda, ElastiCache, S3 Static Hosting
- 🧪 CI/CD Pipelines with GitHub Actions & CodeCatalyst
- 🧠 Claude CLI, Cursor IDE, and AI-native DevOps workflows
- 🧱 Microservices Deployment Architecture on AWS

### 📫 Let's Connect
- 💼 [LinkedIn](https://www.linkedin.com/in/deepakaryan1988)  
- 🐘 [Drupal.org Profile](https://www.drupal.org/u/deepakaryan1988)  
- 📚 [Hashnode Blog](https://debugdeploygrow.hashnode.dev)  
- 🐙 [GitHub](https://github.com/deepakaryan1988)

> 🧠 _"Before DevOps was a buzzword, I was already scaling Drupal on EC2s. Now I'm just rewriting it all as Terraform modules!"_

## 🚀 CI/CD Pipeline
This project includes automated deployment via GitHub Actions.
