# Serverless REST API with AWS Lambda, API Gateway, DynamoDB, and SNS

![Deploy](https://github.com/julietwainoi/ServerlessRESTAPIwithAWS-Lambda-_APIGateway-_DynamoDB/actions/workflows/deploy.yml/badge.svg)

This project implements a fully serverless REST API using:
- **AWS Lambda** (Node.js runtime)
- **Amazon API Gateway**
- **Amazon DynamoDB**
- **Amazon SNS** for alerting
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD

---

## 🧱 Features

- Create (`POST /items`) and read (`GET /items/{id}`) items
- Items are stored in a DynamoDB table
- Sends an email alert via SNS after item creation
- Entire infrastructure is reproducible using Terraform
- Automated deployment via GitHub Actions

---

## 📁 Project Structure

.
├── lambda/ # Contains Lambda source code
│ └── handler.js
├── lambda.zip # Zipped Lambda function for deployment
├── main.tf # Terraform main configuration
├── variables.tf # (Optional) Terraform variables
├── .gitignore # Files to exclude from version control
├── .github/
│ └── workflows/
│ └── deploy.yml # GitHub Actions workflow
└── README.md # This file


---

## 🚀 How It Works

### 1. API Endpoints

| Method | Path           | Description          |
|--------|----------------|----------------------|
| POST   | `/items`       | Create a new item    |
| GET    | `/items/{id}`  | Retrieve item by ID  |

### 2. Data Flow

1. API Gateway receives the request
2. Invokes Lambda function
3. Lambda reads/writes to DynamoDB
4. If it's a `POST`, it publishes to SNS
5. SNS sends email notification

---

## ⚙️ Deployment with Terraform

### 🔐 Prerequisites

- AWS CLI configured with sufficient IAM permissions
- Terraform installed
- Confirmed SNS subscription (see below)

### 🌍 Deploy Manually

```bash
terraform init
terraform plan
terraform apply

💡 Important: Before deploying, zip your Lambda function:
cd lambda
zip -r ../lambda.zip .


📩 SNS Email Alerts

SNS sends an email notification to:

📧 julietwainoi@gmail.com

📌 Note: You must confirm the subscription via the verification email from AWS.

🚀 CI/CD with GitHub Actions
This project uses GitHub Actions for continuous deployment.

✅ Workflow Triggers
Runs automatically on push to the main branch

🔐 Secrets Configuration
In your GitHub repo, navigate to:

Settings → Secrets and Variables → Actions

Add the following secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

These must belong to an IAM user with adequate Terraform permissions.

📂 Workflow File
GitHub Actions workflow is located at:
.github/workflows/deploy.yml

It performs the following steps:

Checks out the repo

Installs Terraform

Runs terraform init, plan, and apply

✅ Status Badge
The top of this README includes a live CI/CD status badge:

markdown

![Deploy](https://github.com/julietwainoi/ServerlessRESTAPIwithAWS-Lambda-_APIGateway-_DynamoDB/actions/workflows/deploy.yml/badge.svg)

🛑 .gitignore Highlights
To keep the repo clean:
# Ignore build artifacts and secrets
node_modules/
lambda.zip
.terraform/
*.tfstate
.env

🧼 Clean Up
To destroy all infrastructure and avoid charges:
terraform destroy

🙋🏽‍♀️ Author
Juliet Wainoi
Built with 💙 using AWS, Node.js & Terraform


📄 License
MIT License



---

Let me know if you'd like help generating the `deploy.yml` file or auto-confirming SNS subscriptions (requires additional scripting).

