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


In your GitHub repo, navigate to:

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<YOUR_ACCOUNT_ID>:role/github-actions-terraform-role
          aws-region: us-west-2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve


📂 Workflow File
GitHub Actions workflow is located at:
.github/workflows/deploy.yml

It performs the following steps:

Checks out the repo

Installs Terraform
y
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
🔒 Authentication & Authorization with Amazon Cognito

To secure API Gateway endpoints, this project uses Amazon Cognito User Pools for authentication and authorization.

🧠 How It Works

Users authenticate via Cognito (using ADMIN_NO_SRP_AUTH or USER_PASSWORD_AUTH).

Cognito returns three tokens:

IdToken – represents the user’s identity (used with API Gateway)

AccessToken – used to call Cognito’s own APIs (e.g. get-user)

RefreshToken – used to renew tokens when they expire

The IdToken is passed to API Gateway as a Bearer token in the Authorization header.

API Gateway validates the token signature against the Cognito User Pool.

🧩 Example: Authenticating and Calling the API
1. Authenticate and retrieve tokens
aws cognito-idp admin-initiate-auth \
  --region us-west-2 \
  --cli-input-json '{
    "UserPoolId": "us-west-2_XXXXXXX",#used to register users
    "ClientId": "YOUR_CLIENT_ID",#app used to give back the tokens just like when trying to login or registering in an app
    "AuthFlow": "ADMIN_NO_SRP_AUTH",
    "AuthParameters": {
      "USERNAME": "user@example.com",
      "PASSWORD": "Password123."
    }
  }'


This command returns an IdToken, AccessToken, and RefreshToken.

2. Use the IdToken to call your API Gateway endpoint
curl -X POST "https://your-api-id.execute-api.us-west-2.amazonaws.com/prod/items" \
  -H "Authorization: <ID_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"id":"item123","name":"Laptop","price":999.99}'


✅ If the IdToken is valid, the request is authorized and processed by your Lambda.
