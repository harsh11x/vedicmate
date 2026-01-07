# AWS Deployment Guide

Complete guide for deploying Vedic Mate AI Service on AWS.

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- EC2 instance or ECS cluster
- Domain name (optional)

## Deployment Options

### 1. EC2 Deployment (Recommended for Start)

#### Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2
2. Launch Instance
3. Choose Ubuntu Server 20.04 LTS
4. Instance Type: t3.medium or larger (for AI processing)
5. Configure Security Group:
   - Inbound: Port 5000 (HTTP) from your IP
   - Inbound: Port 22 (SSH) from your IP
6. Launch and save key pair

#### Step 2: Connect to EC2

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### Step 3: Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git

# Clone or upload your code
git clone your-repo
cd ai_service

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install gunicorn
```

#### Step 4: Configure Environment

```bash
cp .env.example .env
nano .env  # Edit with your settings
```

#### Step 5: Run with Gunicorn

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

#### Step 6: Set up Systemd Service (Auto-start)

```bash
sudo nano /etc/systemd/system/vedic-ai.service
```

Add:
```ini
[Unit]
Description=Vedic Mate AI Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/ai_service
Environment="PATH=/home/ubuntu/ai_service/venv/bin"
ExecStart=/home/ubuntu/ai_service/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable vedic-ai
sudo systemctl start vedic-ai
sudo systemctl status vedic-ai
```

#### Step 7: Configure Nginx (Optional but Recommended)

```bash
sudo apt-get install nginx
sudo nano /etc/nginx/sites-available/vedic-ai
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable:
```bash
sudo ln -s /etc/nginx/sites-available/vedic-ai /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 2. ECS Deployment (Container-based)

#### Step 1: Build Docker Image

```bash
docker build -t vedic-ai-service .
```

#### Step 2: Push to ECR

```bash
aws ecr create-repository --repository-name vedic-ai-service
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin your-account.dkr.ecr.us-east-1.amazonaws.com
docker tag vedic-ai-service:latest your-account.dkr.ecr.us-east-1.amazonaws.com/vedic-ai-service:latest
docker push your-account.dkr.ecr.us-east-1.amazonaws.com/vedic-ai-service:latest
```

#### Step 3: Create ECS Task Definition

Create `task-definition.json`:
```json
{
  "family": "vedic-ai-service",
  "containerDefinitions": [{
    "name": "vedic-ai",
    "image": "your-account.dkr.ecr.us-east-1.amazonaws.com/vedic-ai-service:latest",
    "portMappings": [{
      "containerPort": 5000,
      "protocol": "tcp"
    }],
    "environment": [
      {"name": "PORT", "value": "5000"},
      {"name": "DEBUG", "value": "False"}
    ],
    "memory": 1024,
    "cpu": 512
  }]
}
```

Register:
```bash
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

#### Step 4: Create ECS Service

```bash
aws ecs create-service \
  --cluster your-cluster \
  --service-name vedic-ai-service \
  --task-definition vedic-ai-service \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

### 3. Elastic Beanstalk Deployment

#### Step 1: Install EB CLI

```bash
pip install awsebcli
```

#### Step 2: Initialize

```bash
eb init -p python-3.9 vedic-ai-service
```

#### Step 3: Create Environment

```bash
eb create vedic-ai-env
```

#### Step 4: Deploy

```bash
eb deploy
```

### 4. Lambda Deployment (Serverless)

For serverless deployment, use AWS SAM or Serverless Framework.

## Security Configuration

### Security Groups

- Allow port 5000 only from your Flutter app's IP or ALB
- Allow port 22 (SSH) only from your IP
- Use HTTPS (port 443) with SSL certificate

### IAM Roles

Create IAM role with minimal permissions:
- CloudWatch Logs (for logging)
- S3 (if storing data)
- Secrets Manager (for API keys)

## Monitoring

### CloudWatch

Set up CloudWatch alarms for:
- CPU utilization
- Memory usage
- Request count
- Error rate

### Logging

Configure CloudWatch Logs:
```python
import logging
import boto3

# In app.py
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

## Scaling

### Auto Scaling (EC2)

1. Create Launch Template
2. Create Auto Scaling Group
3. Set min: 1, max: 5 instances
4. Configure scaling policies

### ECS Auto Scaling

```bash
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --scalable-dimension ecs:service:DesiredCount \
  --resource-id service/your-cluster/vedic-ai-service \
  --min-capacity 1 \
  --max-capacity 10
```

## Cost Optimization

- Use Spot Instances for development
- Right-size instances based on usage
- Use CloudWatch to monitor costs
- Set up billing alerts

## Update Flutter App

Update your Flutter app's API configuration:

```dart
// lib/core/config/env.dart
static const String aiServiceUrl = String.fromEnvironment(
  'AI_SERVICE_URL',
  defaultValue: 'https://your-aws-domain.com', // Your AWS server URL
);
```

## Testing Deployment

```bash
# Health check
curl http://your-aws-ip:5000/health

# Test AI chat
curl -X POST http://your-aws-ip:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Tell me about Aries", "conversation_history": [], "user_id": "test"}'
```

## Troubleshooting

### Service not starting
```bash
sudo journalctl -u vedic-ai -f
```

### Check logs
```bash
tail -f /var/log/vedic-ai.log
```

### Restart service
```bash
sudo systemctl restart vedic-ai
```

## Next Steps

1. Set up domain name and SSL
2. Configure CDN (CloudFront)
3. Set up monitoring and alerts
4. Configure auto-scaling
5. Set up backup strategy

