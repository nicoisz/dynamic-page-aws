# Dynamic Page AWS

A serverless web application that displays a dynamic string fetched from AWS SSM Parameter Store. The page automatically updates its content every 3 seconds without requiring a manual refresh.

## Features

- **Infrastructure as Code:** Fully managed via Terraform.
- **Continuous Polling:** Client-side JavaScript updates the header every 3 seconds using `setInterval`.
- **Security First:** 
  - **XSS Protection:** All inputs are HTML-escaped before rendering.
  - **Input Validation:** Restricts values to a maximum of 50 characters and prevents empty strings.
- **Robustness:** Includes error handling for AWS service communication failures.
- **Clean UI:** Minimalist, centered design with modern typography.

## Tech Stack

- **Cloud:** AWS (Lambda, SSM, IAM).
- **IaC:** Terraform.
- **Backend:** Python 3.12 (Lambda).
- **Frontend:** Vanilla HTML/JS/CSS.

## Prerequisites

- AWS CLI configured with appropriate permissions.
- Terraform installed (>= 1.5).
- Python 3.12 (optional, for local testing).

## Deployment

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Deploy Infrastructure:**
   ```bash
   terraform apply
   ```

3. **Access the Web:**
   The command will output the `url` of the Lambda Function. Open it in your browser.

## Usage

To see the dynamic polling in action, change the value of the SSM parameter from your terminal:

```bash
aws ssm put-parameter \
    --name "/app/dynamic-string" \
    --value "Hello from AWS CLI!" \
    --type "String" \
    --overwrite
```

Watch the web page update automatically after 3 seconds!

## Security & QA Notes

The application has been tested against:
- **XSS Attacks:** Attempting to inject `<script>` or `<h1>` tags will result in the literal text being displayed safely.
- **Input Length:** Strings over 50 characters will trigger a validation error message.
- **Empty Inputs:** Strings consisting only of whitespace will trigger an "Input is empty" error.
- **Least Privilege:** IAM roles are scoped specifically to the resources needed for operation.
