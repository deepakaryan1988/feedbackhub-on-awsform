# FeedbackHub on AWS – Roadmap

This roadmap tracks the evolution of **FeedbackHub on AWS** — a Next.js feedback platform deployed on **AWS ECS Fargate** with **Terraform, ALB, MongoDB Atlas, GitHub Actions CI/CD**, and **Blue/Green deployments**.

The roadmap is organized into **phases**, marking each milestone as:
- ✅ Completed
- 🟢 In Progress
- 🔜 Upcoming

---

## **Phase 1 – Foundations** ✅
- AWS Core Services (VPC, ECS, ECR, ALB, IAM, Secrets Manager, RDS basics)
- Terraform Basics (variables, outputs, data sources)
- Docker Basics (containerizing FeedbackHub locally)

---

## **Phase 2 – Project Deployments** ✅
- **Project 1:** Drupal on AWS ECS (Paused after persistent storage issue)
- **Project 2:** Appwrite on AWS ECS (Stable POC completed)
- **Project 3:** FeedbackHub on AWS ECS (Active project)
  - ECS Fargate + ALB + GitHub Actions CI/CD
  - MongoDB Atlas integration (Secrets Manager)
  - Blue/Green deployments

---

## **Phase 3 – Advanced Deployment & Reliability** ✅
- Blue/Green deployments (ECS + ALB)
- ECS Auto Scaling (Target tracking policy)
- CloudWatch Alarms + SNS Notifications

---

## **Phase 4 – Scaling & Observability** 🟢 *(Current Phase)*
- Amazon EKS (Kubernetes) proof-of-concept
- Observability stack (CloudWatch → OpenSearch, Prometheus, Grafana)
- Cost optimization (ECS/EKS scaling costs, Spot capacity testing)

---

## **Phase 5 – AI-Augmented Cloud/MLOps** �
- AWS Bedrock integration (AI features in FeedbackHub)
- AWS SageMaker (basic ML model training & deployment)
- RAG pipelines (Claude/Gemini integration)
- AgentOps concepts (CI/CD for LLM prompt chains)

---

## **Phase 6 – Final Prep & Target Role Readiness** 🔜
- AWS Solutions Architect Associate (SAA)
- AWS DevOps Engineer – Professional
- Interview simulation (system design, infra debugging)
- Portfolio packaging (GitHub, LinkedIn, Resume)

---

📌 **Current Milestone:**  
We are in **Phase 4 – Scaling & Observability**, focusing on Amazon EKS POC and enhanced monitoring.

📌 **Next Major Transition:**  
Project will evolve into **Phase 5 – AI-Augmented Cloud/MLOps**, integrating AI/ML workflows.
