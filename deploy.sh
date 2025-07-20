#!/bin/bash

set -e

DOCKER_USER="dockxam" # Replace with your Docker Hub username
BUILD_TAG=$(date +%s)
HELLO_IMAGE="$DOCKER_USER/python-app:$BUILD_TAG" # Replace with your Docker image name
REVERSE_IMAGE="$DOCKER_USER/reverse-python-app:$BUILD_TAG" # Replace with your Docker image name
NAMESPACE="hello-world"
CHART_NAME="app"
RELEASE_NAME="helloworld"

install_docker() {
  echo "Installing Docker"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  echo "Docker installed"
}

install_kubectl() {
  echo "Installing kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  echo "kubectl installed."
}

install_helm() {
  echo "Installing Helm"
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  echo "Helm installed."
}

if ! command -v docker &> /dev/null; then
  install_docker
  sudo usermod -aG docker "$USER"
  echo "Added $USER to docker group"
else
  echo "Docker already installed"
fi

if ! command -v kubectl &> /dev/null; then
  install_kubectl
else
  echo "kubectl already installed"
fi

if ! command -v helm &> /dev/null; then
  install_helm
  echo "Adding stable Helm repo"
  helm repo add stable https://charts.helm.sh/stable
  helm repo update
else
  echo "Helm already installed"
fi

# Build & Push Docker Images
echo " Building  Hello-World Docker images"
docker build -t $HELLO_IMAGE ./hello-world
docker push $HELLO_IMAGE

echo "Building  Reverse-Hello-World Docker images"
docker build -t $REVERSE_IMAGE ./reverse-hello-world
docker push $REVERSE_IMAGE

# Set Up Namespace 

if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo "Creating namespace $NAMESPACE..."
  kubectl create namespace "$NAMESPACE"
else
  echo "Namespace $NAMESPACE already exists. Skipping creation."
fi


# Deploy via Helm 
echo "Deploying with Helm"
helm upgrade --install $RELEASE_NAME ./app \
  --namespace $NAMESPACE \
  --set helloworld.image=$DOCKER_USER/python-app \
  --set helloworld.tag=$BUILD_TAG \
  --set reversehelloworld.tag=$BUILD_TAG \
  --set reversehelloworld.image=$DOCKER_USER/reverse-python-app

# Wait for pods to be ready 
echo "Waiting for pods to be ready..."
sleep 30s

# Port-forward reverse service to localhost 
echo "Accessing reverse app via port-forward..."
kubectl port-forward svc/hello-world 5001:5000 -n $NAMESPACE &
kubectl port-forward svc/reverse-hello-world 8001:8000 -n $NAMESPACE &
sleep 5

# Curl the response 
echo "Fetching response from hello-world app"
curl http://localhost:5001
echo "Fetching response from reverse app"
curl http://localhost:8001
echo "Response received. You can now access the reverse app at http://localhost:8001"
