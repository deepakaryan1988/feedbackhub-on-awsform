
# GitHub Copilot Instructions – FeedbackHub-on-AWS

## How to Use
Paste these instructions into Copilot Chat or ChatGPT for context-aware code generation, reviews, and onboarding.

## 1️⃣ Project Summary
FeedbackHub-on-AWS is a production-grade feedback platform built with **Next.js** and deployed on **AWS ECS Fargate**. Infrastructure is fully managed via **modular Terraform**. MongoDB Atlas is the primary database. AWS Secrets Manager handles credentials. Deployments use **Blue/Green** via ALB. Auto Scaling + CloudWatch alarms are configured.

---

## 2️⃣ Architecture Overview
- **Frontend & Backend:** Next.js (API routes)
- **Database:** MongoDB Atlas (local & prod URIs)
- **Infrastructure:** ECS Fargate, ALB, Auto Scaling, CloudWatch, SNS
- **IaC:** Modular Terraform (`terraform/`)
- **parent infra to control modular terraform:** infra Terraform (`infra/`)
- **Secrets:** AWS Secrets Manager
- **CI/CD:** GitHub Actions (`.github/workflows/deploy.yml`)
- **AI Integration:** AWS Bedrock (Claude for log summarization)

---

## 3️⃣ Repository Structure
```
/app/                # Next.js app directory (pages, API routes, components, hooks, lib, types)
/docker/             # Dockerfiles and compose files for local/dev/prod
/docs/               # Architecture, setup, and onboarding documentation
/infra/              # Parent Terraform for controlling modular infra
/scripts/            # Shell scripts for build, test, and setup
/terraform/          # Modular Terraform (alb, ecs, cloudwatch, secrets, etc.)
/lambda/             # AWS Lambda functions (e.g., Bedrock log summarizer)
public/              # Static assets (images, favicon, etc.)
package.json         # Project dependencies and scripts
README.md            # Project overview and quickstart
.env.example         # Example environment variables
```
---

## 4️⃣ Development & Deployment Rules
- All Terraform changes must be modular (no monolithic `main.tf`).
- Secrets (DB URIs, API keys) are fetched via **Secrets Manager**.
- Auto Scaling is triggered by CPU (CloudWatch + SNS).
- **No hardcoding** of Account IDs, Subnet IDs, Regions.
- **Integrate with existing ALB, ECS, and Secrets Manager infrastructure—do not re-provision these core resources.**

---

## 5️⃣ Naming Conventions
- **Branches:**  
  - `feature/...` → new features  
  - `fix/...` → bug fixes  
- ✅ Use AWS best practices, modular Terraform
- ✅ Maintain `README.md` with roadmap updates
**Don’t:**


To maximize productivity and clarity, this project supports dedicated Copilot/AI subagents for each major engineering role. Each subagent is optimized for the workflows, best practices, and context of its domain. To invoke a subagent, use the role-specific prompt snippets in [docs/copilot-snippets.md](../docs/copilot-snippets.md) or specify the role in your Copilot/AI prompt.
- **DevOps Subagent:** Infrastructure as Code, CI/CD, AWS, Terraform, Docker, deployment automation, monitoring, and incident response.
- **Security Subagent:** IAM, secrets management, encryption, compliance, vulnerability scanning, and secure coding practices.
- **MLOps/AI Subagent:** AI/ML integration, AWS Bedrock, Lambda, model deployment, data pipelines, and log summarization.
- **Fullstack Subagent:** Next.js, API routes, frontend/backend integration, UI/UX, and end-to-end testing.
- **Cloud Architect Subagent:** Solution design, AWS architecture, scalability, cost optimization, and cross-service integration.
- **SRE Subagent:** Reliability, observability, auto scaling, CloudWatch, alerting, and performance tuning.
- **General/Meta Subagent:** Documentation, onboarding, code review, and meta tasks.

**How to Use:**
- Reference the [Copilot Prompt Snippets](../docs/copilot-snippets.md) for ready-to-use prompts for each subagent.
- When starting a new task, specify the subagent/role in your prompt for best results (e.g., “DevOps subagent: create a new ECS service module in Terraform”).

This approach ensures that Copilot/AI responses are tailored, actionable, and aligned with best practices for each domain.

## Workflow

- **Always create a markdown todo list before taking any action.**
  - This todo list should break down the solution into clear, incremental steps.
  - Use the following format:

  ```markdown
  - [ ] Step 1: Description of the first step
  - [ ] Step 2: Description of the second step
  - [ ] Step 3: Description of the third step
  ```
  - Check off each step as you complete it, and always display the updated todo list to the user.
  - After each step, immediately show the current todo list with the completed step checked off, then proceed to the next step.
  - For long or complex todo lists, consider using emoji (✅, ⏳, 🚧) or progress bars to make status visually clear.
  - If a step fails, display the error, update the todo list to reflect the failure, and attempt to resolve the issue before proceeding to the next step.
  - After completing each major step or logical unit of work, make an incremental commit to keep changes well-documented and easy to review.
  - If you need to pause your work, note the last completed step. To resume, simply continue from the next incomplete step in the todo list.
  - For reference, see the example below of a completed todo list:
  - If multiple contributors are working on the same issue, assign steps, update the todo list collaboratively, and communicate progress frequently to avoid duplication.
  - After all steps are checked off, take a moment to review the solution, check for edge cases, and document any lessons learned or follow-up actions.
  - (Optional) Consider using a script or tool to auto-generate markdown todo lists from issue descriptions or PR templates to streamline workflow setup.

  ```markdown
  - [x] Step 1: Do the first thing
  - [x] Step 2: Do the next thing
  - [x] Step 3: Finalize and review
  ```
  - Do not use HTML or other formats for the todo list.

- Fetch any URLs provided by the user using the `fetch_webpage` tool.
- Understand the problem deeply. Carefully read the issue and think critically about what is required. Use sequential thinking to break down the problem into manageable parts.
- Investigate the codebase. Explore relevant files, search for key functions, and gather context.
- Research the problem on the internet by reading relevant articles, documentation, and forums.
- Develop a clear, step-by-step plan. Break down the fix into manageable, incremental steps. Display those steps in a simple todo list using standard markdown format. Make sure you wrap the todo list in triple backticks so that it is formatted correctly.
- Implement the fix incrementally. Make small, testable code changes.
- Debug as needed. Use debugging techniques to isolate and resolve issues.
- Test frequently. Run tests after each change to verify correctness.
- Iterate until the root cause is fixed and all tests pass.
- Reflect and validate comprehensively. After tests pass, think about the original intent, write additional tests to ensure correctness, and remember there are hidden tests that must also pass before the solution is truly complete.

Refer to the detailed sections below for more information on each step.
## Testing & Validation
- Run all tests and validate Terraform plans before merging.
- Use GitHub Actions CI/CD for every PR and deployment.

## Security & Compliance
- Always use IAM least privilege, encryption, and secure secrets management.
- Follow AWS and company compliance standards for all changes.

## Reference Docs
- [README.md](../README.md)
- [Roadmap](../docs/roadmap.md)
- [Copilot Prompt Snippets](../docs/copilot-snippets.md)

## Maintainer
For questions, open an issue or contact [Deepak Kumar](https://github.com/deepakaryan1988).