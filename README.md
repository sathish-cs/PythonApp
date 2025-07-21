#  Python Hello World Reverse App (Kubernetes + Helm + Docker)

This project demonstrates a microservice architecture using two Python services:

- `hello-world`: A simple Python service that returns a "Hello, World!" message with an ID.
- `reverse-hello-world`: A second service that fetches the message from `hello-world` and returns its reversed form.

The project is containerized using Docker, deployed using **Helm charts**, and runs on a local Kubernetes cluster using **Minikube**.

---

## Prerequisites

Make sure the following are installed and configured:

###  

### Docker

Log in to Docker Hub before building and pushing images:
```bash
docker login
```

## Files & Directories

### hello-world
- A simple Python service that returns a "Hello, World!" message with an ID.
### reverse-hello-world
- A second service that fetches the message from `hello-world` service and returns its reversed.

### app/
Contains the Helm chart used to deploy the application.

- Kubernetes deployments for both services.

- Kubernetes ClusterIP services to access each other internally.

- Configurable values in values.yaml.

### `deploy.sh`

A deployment script that automates:

- Building Docker images for both services  
- Pushing images to Docker Hub repository  
- Installing the application on Minikube using Helm  

## Getting Started

#### Clone the Repository

```
git clone https://github.com/signavio-hiring/coding-challenge-sathish-kumar-c.git
cd coding-challenge-sathish-kumar-c
git checkout python-app
```

```

```

**Run the script:**

>  **Replace your Docker Hub username in the script before running.**

```bash
./deploy.sh
```

