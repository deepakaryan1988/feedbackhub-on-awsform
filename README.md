# FeedbackHub-on-AWSform

**FeedbackHub** is a fullstack Next.js app using MongoDB Atlas. It supports both:
- 🧪 Local development (connects directly to MongoDB Atlas via `feedbackhub‑local` user)
- ☁️ AWS production deployment on ECS (via `feedbackhub` user), with Terraform and AWS Secrets Manager

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
terraform apply
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
  GET /api/db-health
  # should return status 200 if DB is connected
  ```
- **Logs:**
  ```bash
  aws logs tail /ecs/feedbackhub --since 1h --follow --region ap-south-1
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

## 🧑‍💻 Contributing

- Fork the repo
- Work on a feature branch
- Copy `.env.example` and configure `.env.local`
- Submit a PR with meaningful tests if applicable

---

## 📄 License

MIT License