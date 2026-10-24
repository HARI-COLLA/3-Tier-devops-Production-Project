# 🚀 End-to-End Production DevSecOps: 3-Tier Web Application on AWS EKS

![DevSecOps](https://img.shields.io/badge/Security-Shift--Left-red?style=for-the-badge&logo=shield)
![AWS](https://img.shields.io/badge/AWS-EKS%20%7C%20ECR%20%7C%20ALB%20%7C%20VPC-orange?style=for-the-badge&logo=amazon-aws)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.34-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD%20Pipelines-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-Quality%20Gate%20Passed-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## 📌 Executive Summary

Welcome to the **Production 3-Tier DevSecOps Project**! 

This repository documents the complete end-to-end architecture, provisioning, security scanning, continuous delivery, and cloud-native orchestration of a production-ready **Three-Tier Web Application** (ReactJS, Node.js/Express, MongoDB) hosted on **Amazon Web Services (AWS)** using **Amazon Elastic Kubernetes Service (EKS)**.

The core philosophy of this project is **Shift-Left DevSecOps**: integrating automated security validation, static code analysis, software composition analysis (SCA), and container vulnerability assessment directly into the continuous integration pipeline before any code reaches the live Kubernetes cluster.

---

## 🏗️ High-Level Architecture

```
                                  +-------------------+
                                  |   Internet User   |
                                  +---------+---------+
                                            |
                                            v (HTTP 80)
                       +---------------------------------------------+
                       |     AWS Application Load Balancer (ALB)     |
                       |       (Managed by AWS LB Controller)        |
                       +--------------------+------------------------+
                                            |
                         +------------------+------------------+
                         | (Path: /)                           | (Path: /api)
                         v                                     v
             +-----------------------+             +-----------------------+
             |   frontend Service    |             |      api Service      |
             |   (ClusterIP: 3000)   |             |   (ClusterIP: 3500)   |
             +-----------+-----------+             +-----------+-----------+
                         |                                     |
                         v                                     v
             +-----------------------+             +-----------------------+
             |     React Frontend    |             |    Node.js REST API   |
             |     Pod (Replicas)    |             |    Pods (Replicas)    |
             +-----------------------+             +-----------+-----------+
                                                               |
                                                               v (Port 27017)
                                                   +-----------------------+
                                                   |   mongodb-svc Service |
                                                   |   (ClusterIP: 27017)  |
                                                   +-----------+-----------+
                                                               |
                                                               v
                                                   +-----------------------+
                                                   |      MongoDB Pod      |
                                                   |  (Stateful with PVC)  |
                                                   +-----------+-----------+
                                                               |
                                                               v
                                                   +-----------------------+
                                                   |  EBS PersistentVolume |
                                                   +-----------------------+
```

---

## 🧩 The Three Tiers

### 1. Presentation Tier (Frontend)
- **Framework:** ReactJS (Single-Page Application).
- **Service:** Kubernetes `ClusterIP` exposing port `3000`.
- **Communication:** Configured with relative API endpoint `/api/tasks`, allowing clean reverse-proxy routing through the Application Load Balancer without cross-origin (CORS) complexities.

### 2. Logic Tier (Backend API)
- **Runtime:** Node.js with Express.js framework.
- **Service:** Kubernetes `ClusterIP` exposing port `3500`.
- **Endpoints:** RESTful API exposing `/api/tasks` for full CRUD operations.
- **Resilience:** Multi-pod replica deployment with automated rolling updates.

### 3. Data Tier (Database)
- **Engine:** MongoDB 4.4.
- **Data Persistence:** Backed by Kubernetes `PersistentVolume` and `PersistentVolumeClaim` (PVC) to guarantee zero data loss across pod restarts or rescheduling.
- **Credential Management:** Sensitive credentials (`MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD`) stored and injected via Kubernetes `Secrets`.

---

## 🛠️ Complete DevOps & DevSecOps Toolchain

| Area | Tool | Purpose |
| :--- | :--- | :--- |
| **Cloud Provider** | AWS (`ap-south-1` Mumbai) | Infrastructure hosting (EKS, ECR, EC2, VPC, S3, DynamoDB, IAM). |
| **Infrastructure as Code** | Terraform | Codified VPC, subnetting, security groups, EC2, and IAM roles with S3 remote state and DynamoDB state locking. |
| **CI/CD Automation** | Jenkins LTS (Java 21) | Orchestrates the multi-stage declarative pipelines for frontend and backend. |
| **Static Code Analysis** | SonarQube | Enforces clean code quality, detects code smells, bugs, and security hotspots. |
| **Quality Gate** | SonarQube Webhooks | Halts deployment immediately if quality criteria are not satisfied. |
| **Dependency Scanning** | OWASP Dependency-Check | Software Composition Analysis (SCA) checking dependencies against the CVE database. |
| **Vulnerability Scanning** | Trivy | Scans raw filesystem code and final built container images for vulnerabilities. |
| **Containerization** | Docker | Multi-stage container builds creating lightweight runtime images. |
| **Container Registry** | AWS ECR (Private) | Private, highly secure repository hosting versioned container images. |
| **Kubernetes Orchestration** | AWS EKS (v1.34) | Managed production Kubernetes cluster provisioned via `eksctl`. |
| **Ingress & Routing** | AWS Load Balancer Controller | Dynamically provisions and manages an external AWS Application Load Balancer. |
| **GitOps Automation** | Git | Automatic manifest image tag patching and commit back to the repository (`main` branch). |

---

## 🔐 The 11-Stage DevSecOps Pipeline

Both `Jenkinsfile-Backend` and `Jenkinsfile-Frontend` follow a strict **Shift-Left Security** approach:

```mermaid
flowchart LR
    A[1. Clean Workspace] --> B[2. Git Checkout]
    B --> C[3. SonarQube Scan]
    C --> D[4. Quality Gate]
    D --> E[5. OWASP Dependency Check]
    E --> F[6. Trivy File Scan]
    F --> G[7. Docker Build]
    G --> H[8. AWS ECR Push]
    H --> I[9. Trivy Image Scan]
    I --> J[10. Manifest Checkout]
    J --> K[11. GitOps Image Update]
```

1. **Workspace Hygiene:** Cleans the workspace (`cleanWs()`) to eliminate cached dependencies or artifacts from previous builds.
2. **Source Checkout:** Clones the verified commit from the `main` branch of GitHub.
3. **SonarQube Analysis:** Scans code against SonarQube Quality Profiles to catch bugs, vulnerabilities, and code duplication.
4. **Quality Gate:** Webhook callback from SonarQube pauses the pipeline; if quality thresholds fail, the pipeline terminates.
5. **OWASP Dependency-Check:** Audits `package.json` third-party packages against the National Vulnerability Database (NVD).
6. **Trivy File Scan:** Security inspection across the project repository files to catch misconfigurations and plain-text secrets.
7. **Docker Container Build:** Packages the application into a Docker container.
8. **AWS ECR Push:** Authenticates securely via AWS STS temporary token, tags the image with the unique Jenkins `${BUILD_NUMBER}`, and pushes to AWS ECR.
9. **Trivy Container Scan:** Scans the final container image layers for operating system and library CVEs.
10. **Manifest Checkout:** Pulls the latest Kubernetes deployment manifests.
11. **GitOps Tag Update & Push:** Uses `sed` to update the container tag in `deployment.yaml` with the latest build number and pushes the commit back to GitHub.

---

## 📁 Repository Directory Structure

```text
.
├── Application-Code/
│   ├── backend/                      # Node.js Express REST API
│   │   ├── models/                   # Mongoose data models
│   │   ├── routes/                   # API route handlers (/api/tasks)
│   │   ├── Dockerfile                # Backend containerization spec
│   │   ├── index.js                  # Express server entry point
│   │   └── package.json
│   └── frontend/                     # ReactJS Single Page Application
│       ├── public/                   # Static assets & HTML template
│       ├── src/                      # React components & UI logic
│       ├── Dockerfile                # Frontend containerization spec
│       └── package.json
├── Jenkins-Pipeline-Code/
│   ├── Jenkinsfile-Backend           # 11-stage declarative pipeline for backend
│   └── Jenkinsfile-Frontend          # 11-stage declarative pipeline for frontend
├── Jenkins-Server-TF/                # Infrastructure as Code (Terraform)
│   ├── backend.tf                    # S3 remote state & DynamoDB lock config
│   ├── provider.tf                   # AWS provider definition (ap-south-1)
│   ├── vpc.tf                        # Dedicated VPC, subnets, IGW, route tables
│   ├── ec2.tf                        # EC2 instance definition with IAM profile
│   ├── iam-role.tf                   # IAM role for EC2 instance
│   ├── iam-policy.tf                 # IAM policy attachments
│   ├── iam-instance-profile.tf       # EC2 Instance Profile linking
│   ├── tools-install.sh              # User-data bootstrap script for tools
│   ├── variables.tf                  # Variable declarations
│   ├── variables.tfvars              # Variable values
│   └── output.tf                     # Exported instance IPs & URLs
├── Kubernetes-Manifests-file/
│   ├── Backend/
│   │   ├── deployment.yaml           # Backend multi-replica Deployment
│   │   └── service.yaml              # Backend ClusterIP Service (port 3500)
│   ├── Frontend/
│   │   ├── deployment.yaml           # Frontend Deployment
│   │   └── service.yaml              # Frontend ClusterIP Service (port 3000)
│   ├── Database/
│   │   ├── deployment.yaml           # MongoDB Deployment
│   │   ├── pv.yaml                   # PersistentVolume definition
│   │   ├── pvc.yaml                  # PersistentVolumeClaim definition
│   │   ├── secrets.yaml              # Base64 encoded DB credentials
│   │   └── service.yaml              # MongoDB ClusterIP Service (port 27017)
│   └── ingress.yaml                  # AWS Application Load Balancer Ingress
├── .gitignore
└── README.md
```

---

## 🚀 Step-by-Step Implementation Guide

### Phase 1: Provisioning the Jenkins & Security Server with Terraform

1. **Remote State S3 Bucket & DynamoDB Table:**
   ```bash
   aws s3api create-bucket --bucket three-tier-tfstate-251128026767 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
   aws dynamodb create-table --table-name Lock-Files --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region ap-south-1
   ```

2. **Initialize and Apply Terraform:**
   ```bash
   cd Jenkins-Server-TF
   terraform init
   terraform validate
   terraform plan -var-file="variables.tfvars"
   terraform apply -auto-approve -var-file="variables.tfvars"
   ```

   *The bootstrap script automatically installs Java 21, Jenkins, Docker, SonarQube, AWS CLI v2, kubectl, eksctl, Terraform, Trivy, and Helm.*

---

### Phase 2: Configuring Jenkins & SonarQube

1. **Access Services:**
   - **Jenkins:** `http://<SERVER_IP>:8080`
   - **SonarQube:** `http://<SERVER_IP>:9000`

2. **Jenkins Tools Setup:**
   - **JDK:** Name `jdk`, JAVA_HOME `/usr/lib/jvm/java-21-openjdk-amd64`
   - **NodeJS:** Name `nodejs`, version `NodeJS 18.x`
   - **SonarQube Scanner:** Name `sonar-scanner`
   - **Dependency-Check:** Name `DP-Check`

3. **SonarQube Integration:**
   - Generated token `jenkins-token` under **My Account > Security**.
   - Created Webhook in SonarQube: `http://<SERVER_IP>:8080/sonarqube-webhook/`.
   - Linked in Jenkins System Configuration with ID `sonar-token`.

4. **ECR & Account Credentials in Jenkins:**
   - `ACCOUNT_ID`: AWS Account ID (Secret text).
   - `ECR_REPO1`: `frontend` (Secret text).
   - `ECR_REPO2`: `backend` (Secret text).
   - `GITHUB`: Username and Token for source code checkout.
   - `github`: Personal Access Token for manifest push.

---

### Phase 3: EKS Cluster Provisioning & Ingress Setup

1. **Create the EKS Cluster with `eksctl`:**
   ```bash
   eksctl create cluster \
     --name three-tier-cluster \
     --region ap-south-1 \
     --node-type c7i-flex.large \
     --nodes-min 2 \
     --nodes-max 2
   ```

2. **Enable IAM OIDC Provider:**
   ```bash
   eksctl utils associate-iam-oidc-provider \
     --region=ap-south-1 \
     --cluster=three-tier-cluster \
     --approve
   ```

3. **Install AWS Load Balancer Controller:**
   ```bash
   # Create IAM Policy
   curl -sO https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
   aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

   # Create IAM Service Account (IRSA)
   eksctl create iamserviceaccount \
     --cluster=three-tier-cluster \
     --namespace=kube-system \
     --name=aws-load-balancer-controller \
     --role-name AmazonEKSLoadBalancerControllerRole \
     --attach-policy-arn=arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
     --approve \
     --region=ap-south-1

   # Deploy via Helm
   helm repo add eks https://aws.github.io/eks-charts
   helm repo update eks
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     -n kube-system \
     --set clusterName=three-tier-cluster \
     --set serviceAccount.create=false \
     --set serviceAccount.name=aws-load-balancer-controller
   ```

---

### Phase 4: Deploying Kubernetes Manifests

```bash
# 1. Create dedicated namespace and ECR secret
kubectl create namespace three-tier
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ap-south-1) \
  --namespace=three-tier

# 2. Deploy Database, Backend, and Frontend
kubectl apply -f Kubernetes-Manifests-file/Database/
kubectl apply -f Kubernetes-Manifests-file/Backend/
kubectl apply -f Kubernetes-Manifests-file/Frontend/
kubectl apply -f Kubernetes-Manifests-file/ingress.yaml
```

---

## 💡 Production Engineering Challenges Overcome

Real production engineering is defined by how unexpected blockers are diagnosed and resolved:

### 1. AWS Organization Service Control Policy (SCP) Deny
- **Symptom:** AWS CLI and Terraform commands failed with `explicit deny in a service control policy`.
- **Diagnosis:** Discovered through IAM Policy Simulator (`aws iam simulate-principal-policy`) that the account belonged to a managed organization OU with restrictive root SCPs blocking EC2, ECR, and EKS.
- **Resolution:** Re-architected and migrated the infrastructure deployment to a fully owned standalone AWS account with unrestricted root authority.

### 2. Free Tier Instance Guardrail Enforcement
- **Symptom:** EC2 launch rejected with `InvalidParameterCombination: The specified instance type is not eligible for Free Tier`.
- **Diagnosis:** The account had automated billing policies enforcing free-tier eligible instance types.
- **Resolution:** Queried the AWS API using `aws ec2 describe-instance-types --filters "Name=free-tier-eligible,Values=true"`. Selected `m7i-flex.large` (2 vCPU, 8 GB RAM) for the Jenkins server and `c7i-flex.large` for EKS nodes, guaranteeing enterprise-grade performance while honoring billing guardrails.

### 3. Jenkins LTS Java 21 Migration
- **Symptom:** Jenkins service failed to start on Ubuntu 22.04 (`status=1/FAILURE`).
- **Diagnosis:** Modern Jenkins LTS releases officially deprecated Java 17 and require Java 21+.
- **Resolution:** Upgraded to `openjdk-21-jdk`, configured alternatives, and added a 4GB Swapfile to ensure smooth Docker and security scanning execution without Out-Of-Memory (OOM) crashes.

### 4. Non-Interactive Git Token Authentication in CI
- **Symptom:** Pipeline Stage 11 failed with `fatal: could not read Password for 'https://****@github.com': No such device or address`.
- **Diagnosis:** Headless CI terminals cannot prompt for passwords interactively when using `https://${TOKEN}@github.com`.
- **Resolution:** Updated push commands to explicit basic auth: `https://${GIT_USER_NAME}:${GITHUB_TOKEN}@github.com/...`, eliminating password prompts and enabling autonomous GitOps manifest updates.

---

## 🎯 Verification & Health Checks

Verify your live deployment with:

```bash
# Check Pods, Services, and Ingress
kubectl get pods,svc,ingress -n three-tier -o wide
```

Expected Output:
```text
NAME                            READY   STATUS    RESTARTS   AGE   IP               NODE
pod/api-64c4794d8-hnzs7         1/1     Running   0          5m    192.168.26.88    ip-192-168-8-88
pod/api-64c4794d8-hrgjs         1/1     Running   0          5m    192.168.33.121   ip-192-168-58-217
pod/frontend-6f7f4966b7-4zl5w   1/1     Running   0          5m    192.168.56.225   ip-192-168-58-217
pod/mongodb-55d4c585b-x52r8     1/1     Running   0          5m    192.168.41.15    ip-192-168-58-217

NAME                               CLASS   HOSTS   ADDRESS                                                                 PORTS
ingress.networking.k8s.io/mainlb   alb     *       k8s-threetie-mainlb-73c240e86c-185679078.ap-south-1.elb.amazonaws.com   80
```

---

## 👨‍💻 Author

**Harinath Reddy M**  
- **GitHub:** [@HARI-COLLA](https://github.com/HARI-COLLA)  
- **Repository:** [3-Tier-devops-Production-Project](https://github.com/HARI-COLLA/3-Tier-devops-Production-Project)

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
