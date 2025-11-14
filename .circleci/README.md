# CircleCI Configuration

This directory contains the CircleCI pipeline configuration for automated deployment of the application to AWS ECS.

## Pipeline Overview

The pipeline automatically builds and deploys the application when changes are merged to the `main` branch:

1. **Build & Push Image**: Builds Docker image from `application/` directory and pushes to ECR
2. **Deploy to ECS**: Updates ECS service with the new Docker image

## Required Configuration

### CircleCI Context: `aws-access`

This pipeline uses the **`aws-access` context** for AWS authentication, which should already be configured in your CircleCI organization with:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

The context is automatically applied to all jobs in the workflow.

### Project Environment Variables

Configure these environment variables in your CircleCI **project settings**:

- `ECR_REPOSITORY_NAME`: Name of the ECR repository
  - Get from Terraform output: `terraform output ecr_repository_name`
  - Example: `stori-challenge-app`
- `ECS_CLUSTER_NAME`: Name of the ECS cluster
  - Get from Terraform output: `terraform output ecs_cluster_name`
  - Example: `stori-challenge-cluster`
- `ECS_SERVICE_NAME`: Name of the ECS service
  - Get from Terraform output: `terraform output ecs_service_name`
  - Example: `stori-challenge-service`
- `CONTAINER_NAME`: Name of the container in task definition
  - Default: `stori-app`
- `AWS_REGION`: AWS region where resources are deployed
  - Example: `us-east-2`

## Setup Instructions

### 1. Deploy Infrastructure with Terraform

First, deploy the infrastructure including the ECR repository:

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

Save the output values:
```bash
terraform output ecr_repository_name
terraform output ecs_cluster_name
terraform output ecs_service_name
```

### 2. Verify CircleCI Context

Ensure the **`aws-access` context** exists in your CircleCI organization:

1. Go to CircleCI → Organization Settings → Contexts
2. Verify `aws-access` context exists with AWS credentials
3. If not created, create it with:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_DEFAULT_REGION`: `us-east-2`

> **Note**: This context should already be configured if you're using it in other projects (fullstack-challenge, fullstack-test).

### 3. Configure CircleCI Project

1. Go to CircleCI dashboard → Projects
2. Set up your project from GitHub: `jaimefrancosalazar/stori-take-home-challenge`
3. Go to Project Settings → Environment Variables
4. Add the following project-specific environment variables:

```
AWS_REGION=us-east-2
ECR_REPOSITORY_NAME=stori-challenge-app
ECS_CLUSTER_NAME=stori-challenge-cluster
ECS_SERVICE_NAME=stori-challenge-service
CONTAINER_NAME=stori-app
```

> **Important**: AWS credentials come from the `aws-access` context, NOT from project environment variables.

### 4. Initial Image Push

For the first deployment, you need to manually push an initial image to ECR:

```bash
# Get ECR repository URL
ECR_REPO=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $ECR_REPO

# Build and push image
cd application/
docker build -t stori-challenge-app .
docker tag stori-challenge-app:latest $ECR_REPO:latest
docker push $ECR_REPO:latest
```

Then update Terraform to use the ECR image:

```bash
# In terraform/environments/dev/terraform.tfvars
container_image = "123456789012.dkr.ecr.us-east-2.amazonaws.com/stori-challenge-app:latest"

# Apply changes
terraform apply
```

### 5. Test the Pipeline

1. Make a change to the application code in `application/`
2. Commit and push to a feature branch
3. Create a pull request to `main`
4. Merge the PR
5. CircleCI will automatically:
   - Build the Docker image
   - Push to ECR with commit SHA tag
   - Update ECS service with new image
   - Wait for deployment to complete

## Pipeline Features

### Image Tagging Strategy

Each build creates two tags:
- `${CIRCLE_SHA1}`: Git commit SHA for traceability
- `latest`: Points to the most recent build

### Deployment Verification

The pipeline waits for ECS to complete the deployment and verifies:
- New task definition is registered
- Service is updated
- New tasks are running and healthy
- Old tasks are stopped

Maximum wait time: ~16 minutes (50 polls × 20 seconds)

### Branch Protection

The pipeline only runs on the `main` branch to prevent accidental deployments from feature branches.

## Monitoring Deployments

### View Pipeline Status

- CircleCI Dashboard: https://app.circleci.com/pipelines/github/YOUR_USERNAME/stori-take-home-challenge
- Check workflow status, logs, and timing

### View ECS Deployment

```bash
# Check service status
aws ecs describe-services \
  --cluster stori-challenge-cluster \
  --services stori-challenge-service \
  --region us-east-2

# Check running tasks
aws ecs list-tasks \
  --cluster stori-challenge-cluster \
  --service-name stori-challenge-service \
  --region us-east-2

# View task logs
aws logs tail /ecs/stori-challenge --follow --region us-east-2
```

### Verify Application

After deployment completes, test the application:

```bash
ALB_URL=$(terraform output -raw alb_url)
curl $ALB_URL
```

## Rollback

If a deployment fails or introduces issues:

### Option 1: Revert Code and Redeploy

```bash
git revert <bad-commit-sha>
git push origin main
```

CircleCI will automatically deploy the previous version.

### Option 2: Manual Rollback via AWS Console

1. Go to ECS Console → Clusters → stori-challenge-cluster
2. Select the service → Update
3. Choose previous task definition revision
4. Update service

### Option 3: Force Previous Image

```bash
aws ecs update-service \
  --cluster stori-challenge-cluster \
  --service stori-challenge-service \
  --force-new-deployment \
  --task-definition stori-challenge:<previous-revision> \
  --region us-east-2
```

## Cost Considerations

- **ECR Storage**: ~$0.10/GB/month (lifecycle policy cleans up old images)
- **Data Transfer**: ECR → ECS in same region is free
- **CircleCI**: Check your plan's build minutes

## Troubleshooting

### Build Fails - Docker Build Error

Check `application/Dockerfile` syntax and base image availability.

### Push Fails - ECR Authentication

Verify:
- `aws-access` context is configured and accessible by the project
- AWS credentials in context have ECR permissions (`ecr:*` or `AmazonEC2ContainerRegistryPowerUser`)
- ECR repository exists
- Repository name matches environment variable

### Deploy Fails - ECS Update Error

Verify:
- `aws-access` context credentials have ECS permissions (`ecs:*` or `AmazonECS_FullAccess`)
- AWS credentials can pass execution role to ECS tasks (needs `iam:PassRole` permission)
- ECS cluster and service names are correct
- Task definition is valid

### Deploy Hangs - Service Not Stabilizing

Check:
- ECS service events in AWS Console
- Task health checks are passing
- ALB target health
- Container logs for errors

```bash
# Get failed task ARN
TASK_ARN=$(aws ecs list-tasks \
  --cluster stori-challenge-cluster \
  --desired-status STOPPED \
  --region us-east-2 \
  --query 'taskArns[0]' --output text)

# Check why task stopped
aws ecs describe-tasks \
  --cluster stori-challenge-cluster \
  --tasks $TASK_ARN \
  --region us-east-2 \
  --query 'tasks[0].stoppedReason'
```

## Security Best Practices

1. **Use CircleCI Contexts**: Store AWS credentials in organization contexts, not project variables
2. **Principle of least privilege**: Grant only necessary IAM permissions
3. **Enable ECR image scanning**: Detect vulnerabilities automatically (already enabled in Terraform)
4. **Rotate credentials regularly**: Rotate AWS access keys every 90 days
5. **Restrict context access**: Limit which teams/users can use the `aws-access` context
6. **Use secrets management**: Store sensitive application data in AWS Secrets Manager
7. **Review CloudTrail logs**: Monitor API calls from CircleCI deployments

## References

- [CircleCI AWS ECR Orb](https://circleci.com/developer/orbs/orb/circleci/aws-ecr)
- [CircleCI AWS ECS Orb](https://circleci.com/developer/orbs/orb/circleci/aws-ecs)
- [CircleCI Contexts Documentation](https://circleci.com/docs/contexts/)
