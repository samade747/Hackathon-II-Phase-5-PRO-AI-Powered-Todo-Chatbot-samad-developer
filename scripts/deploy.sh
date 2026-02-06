#!/bin/bash

# Deployment script for AI-Powered Todo Chatbot
# This script provides various deployment operations for the application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Function to display usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  deploy          Deploy the application to Kubernetes"
    echo "  upgrade         Upgrade the existing deployment"
    echo "  rollback        Rollback to the previous version"
    echo "  delete          Delete the application from Kubernetes"
    echo "  status          Check the status of the deployment"
    echo "  logs            Show application logs"
    echo "  scale           Scale the application deployments"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 deploy --set frontend.replicaCount=3"
    echo "  $0 upgrade --reuse-values"
    echo "  $0 scale frontend 5"
    echo "  $0 logs frontend"
    exit 1
}

# Check if required tools are installed
check_prerequisites() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        print_error "helm is not installed. Please install helm first."
        exit 1
    fi
}

# Deploy the application
deploy() {
    print_status "Deploying AI-Powered Todo Chatbot application..."

    # Check if Helm chart exists
    if [ ! -d "charts/todo-chatbot" ]; then
        print_error "Helm chart directory not found. Make sure you're running this script from the project root."
        exit 1
    fi

    # Install or upgrade the Helm chart
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
        --set ingress.hosts[0].paths[0].pathType=Prefix \
        "$@"

    print_status "Application deployed successfully!"
}

# Upgrade the existing deployment
upgrade() {
    print_status "Upgrading AI-Powered Todo Chatbot application..."

    # Upgrade the Helm release
    helm upgrade todo-chatbot ./charts/todo-chatbot \
        --namespace todo-chatbot \
        "$@"

    print_status "Application upgraded successfully!"
}

# Rollback to the previous version
rollback() {
    print_status "Rolling back to the previous version..."

    # Rollback the Helm release
    helm rollback todo-chatbot --namespace todo-chatbot

    print_status "Application rolled back successfully!"
}

# Delete the application
delete() {
    print_status "Deleting AI-Powered Todo Chatbot application..."

    # Uninstall the Helm release
    helm uninstall todo-chatbot --namespace todo-chatbot

    print_status "Application deleted successfully!"
}

# Check the status of the deployment
status() {
    print_header "Deployment Status"

    # Show Helm status
    echo "Helm Release Status:"
    helm status todo-chatbot --namespace todo-chatbot

    echo ""
    echo "Kubernetes Resources:"
    kubectl get all -n todo-chatbot

    echo ""
    echo "Ingress Status:"
    kubectl get ingress -n todo-chatbot

    echo ""
    echo "Persistent Volumes (if any):"
    kubectl get pvc -n todo-chatbot
}

# Show application logs
logs() {
    local component=${1:-"all"}

    case $component in
        "frontend"|"backend")
            print_status "Showing logs for $component..."
            kubectl logs -l app=todo-chatbot-$component -n todo-chatbot --tail=100 -f
            ;;
        "all")
            print_status "Showing logs for all components..."
            echo "=== Frontend Logs ==="
            kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot --tail=50
            echo ""
            echo "=== Backend Logs ==="
            kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50
            ;;
        *)
            print_error "Invalid component: $component. Use 'frontend', 'backend', or 'all'."
            exit 1
            ;;
    esac
}

# Scale the application deployments
scale() {
    local component=${1}
    local replicas=${2}

    if [ -z "$component" ] || [ -z "$replicas" ]; then
        print_error "Usage: $0 scale <component> <replicas>"
        print_error "Example: $0 scale frontend 5"
        exit 1
    fi

    case $component in
        "frontend")
            kubectl scale deployment todo-chatbot-frontend -n todo-chatbot --replicas=$replicas
            ;;
        "backend")
            kubectl scale deployment todo-chatbot-backend -n todo-chatbot --replicas=$replicas
            ;;
        *)
            print_error "Invalid component: $component. Use 'frontend' or 'backend'."
            exit 1
            ;;
    esac

    print_status "$component scaled to $replicas replicas."
}

# Main execution based on command
case "${1:-"help"}" in
    "deploy")
        shift
        check_prerequisites
        deploy "$@"
        ;;
    "upgrade")
        shift
        check_prerequisites
        upgrade "$@"
        ;;
    "rollback")
        check_prerequisites
        rollback
        ;;
    "delete")
        check_prerequisites
        delete
        ;;
    "status")
        check_prerequisites
        status
        ;;
    "logs")
        shift
        check_prerequisites
        logs "$@"
        ;;
    "scale")
        shift
        check_prerequisites
        scale "$@"
        ;;
    "help"|*)
        usage
        ;;
esac