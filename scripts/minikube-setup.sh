#!/bin/bash

# Script to set up and deploy the AI-Powered Todo Chatbot on Minikube
# This script will start Minikube, enable necessary addons, and deploy the application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command -v minikube &> /dev/null; then
        print_error "minikube is not installed. Please install minikube first."
        exit 1
    fi

    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed. Please install helm first."
        exit 1
    fi

    print_status "All prerequisites are installed."
}

# Start Minikube cluster
start_minikube() {
    print_status "Starting Minikube cluster..."

    # Check if Minikube is already running
    if minikube status &> /dev/null; then
        print_status "Minikube is already running."
        return 0
    fi

    # Start Minikube with sufficient resources for the application
    minikube start --cpus=4 --memory=8192 --disk-size=20g

    print_status "Minikube cluster started successfully."
}

# Enable required addons
enable_addons() {
    print_status "Enabling required Minikube addons..."

    # Enable ingress addon for external access
    minikube addons enable ingress
    print_status "Ingress addon enabled."

    # Enable metrics-server for HPA functionality
    minikube addons enable metrics-server
    print_status "Metrics-server addon enabled."
}

# Wait for ingress controller to be ready
wait_for_ingress() {
    print_status "Waiting for ingress controller to be ready..."

    # Wait for ingress controller pods to be ready
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=180s

    print_status "Ingress controller is ready."
}

# Deploy the application using Helm
deploy_application() {
    print_status "Deploying AI-Powered Todo Chatbot application..."

    # Navigate to the charts directory
    if [ ! -d "charts/todo-chatbot" ]; then
        print_error "Helm chart directory not found. Make sure you're running this script from the project root."
        exit 1
    fi

    # Install the Helm chart
    # You can customize these values based on your environment
    helm upgrade --install todo-chatbot ./charts/todo-chatbot \
        --namespace todo-chatbot \
        --create-namespace \
        --set global.namespace=todo-chatbot \
        --set frontend.image.repository=todo-chatbot-frontend \
        --set frontend.image.tag=latest \
        --set backend.image.repository=todo-chatbot-backend \
        --set backend.image.tag=latest \
        --set ingress.hosts[0].host=todo-chatbot.local \
        --set ingress.hosts[0].paths[0].path='/' \
        --set ingress.hosts[0].paths[0].pathType=Prefix

    print_status "Application deployment initiated."
}

# Wait for deployments to be ready
wait_for_deployments() {
    print_status "Waiting for deployments to be ready..."

    # Wait for backend deployment
    kubectl wait --namespace todo-chatbot \
      --for=condition=ready pod \
      --selector=app=todo-chatbot-backend \
      --timeout=300s

    # Wait for frontend deployment
    kubectl wait --namespace todo-chatbot \
      --for=condition=ready pod \
      --selector=app=todo-chatbot-frontend \
      --timeout=300s

    print_status "All deployments are ready."
}

# Display application access information
display_access_info() {
    print_status "Application deployed successfully!"

    echo ""
    echo "=========================================="
    echo "  AI-Powered Todo Chatbot Access Info"
    echo "=========================================="
    echo "Frontend URL: http://todo-chatbot.local"
    echo "Backend API: http://todo-chatbot.local/api"
    echo "Health Check: http://todo-chatbot.local/health"
    echo ""
    echo "To access the application:"
    echo "1. Add the following line to your /etc/hosts file:"
    echo "   $(minikube ip) todo-chatbot.local"
    echo ""
    echo "2. Open your browser and navigate to http://todo-chatbot.local"
    echo "=========================================="
    echo ""
}

# Main execution
main() {
    print_status "Starting AI-Powered Todo Chatbot deployment on Minikube..."

    check_prerequisites
    start_minikube
    enable_addons
    wait_for_ingress
    deploy_application
    wait_for_deployments
    display_access_info

    print_status "Deployment completed successfully!"
    print_status "Run 'kubectl get pods -n todo-chatbot' to check pod status."
}

# Run the main function
main "$@"