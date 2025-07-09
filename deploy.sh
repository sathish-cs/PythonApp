#!/bin/bash

set -e

DOCKER_USER="dockxam" # Replace with your Docker Hub username
BUILD_TAG=$(date +%s)
HELLO_IMAGE="$DOCKER_USER/python-app:$BUILD_TAG" # Replace with your Docker image name
REVERSE_IMAGE="$DOCKER_USER/reverse-python-app:$BUILD_TAG" # Replace with your Docker image name
NAMESPACE="hello-world"
CHART_NAME="app"
RELEASE_NAME="helloworld"

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
