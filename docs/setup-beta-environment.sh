#!/bin/bash

# Beta Testing Environment Setup Script
# This script sets up the necessary environment for the beta testing program

set -e

echo "🚀 Setting up Beta Testing Environment..."

# Configuration
BETA_NAMESPACE="beta-testing"
TEST_ENVIRONMENTS_NAMESPACE="test-environments"
ARGOCD_NAMESPACE="argocd"
KARGO_NAMESPACE="kargo"

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

# Check if kubectl is available
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_status "Prerequisites check passed ✓"
}

# Create namespaces
create_namespaces() {
    print_status "Creating namespaces..."
    
    kubectl create namespace ${BETA_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace ${TEST_ENVIRONMENTS_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
    
    print_status "Namespaces created ✓"
}

# Create RBAC configurations
create_rbac() {
    print_status "Creating RBAC configurations..."
    
    # Service account for beta testing workflows
    kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: beta-testing-workflows
  namespace: ${BETA_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: beta-testing-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: beta-testing-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: beta-testing-role
subjects:
- kind: ServiceAccount
  name: beta-testing-workflows
  namespace: ${BETA_NAMESPACE}
EOF
    
    print_status "RBAC configurations created ✓"
}

# Create ConfigMaps for configuration
create_configmaps() {
    print_status "Creating configuration ConfigMaps..."
    
    kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: beta-testing-config
  namespace: ${BETA_NAMESPACE}
data:
  beta-program-duration: "4-weeks"
  environment-timeout: "30"
  cleanup-delay: "5"
  max-concurrent-environments: "10"
  log-level: "info"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: quality-gate-config
  namespace: ${BETA_NAMESPACE}
data:
  thresholds.yaml: |
    functional_tests:
      pass_rate_min: 95
      duration_max: 300
    performance_tests:
      response_time_p95_max: 2000
      throughput_min: 100
    security_tests:
      critical_vulnerabilities_max: 0
      high_vulnerabilities_max: 5
    environment_health:
      availability_min: 99.5
      response_time_max: 5000
EOF
    
    print_status "Configuration ConfigMaps created ✓"
}

# Create secrets (placeholder - should be updated with actual values)
create_secrets() {
    print_status "Creating placeholder secrets..."
    
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: beta-testing-secrets
  namespace: ${BETA_NAMESPACE}
type: Opaque
stringData:
  # These should be replaced with actual values
  bitbucket-token: "placeholder-bitbucket-token"
  argocd-token: "placeholder-argocd-token"
  kargo-password: "placeholder-kargo-password"
  docker-hub-token: "placeholder-docker-hub-token"
EOF
    
    print_warning "⚠️  Placeholder secrets created - please update with actual values"
}

# Deploy monitoring
deploy_monitoring() {
    print_status "Deploying monitoring configurations..."
    
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: beta-testing-metrics
  namespace: ${BETA_NAMESPACE}
  labels:
    app: beta-testing-metrics
spec:
  selector:
    app: beta-testing-metrics
  ports:
  - port: 8080
    targetPort: 8080
    name: metrics
---
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: beta-testing-metrics
  namespace: ${BETA_NAMESPACE}
  labels:
    app: beta-testing-metrics
spec:
  selector:
    matchLabels:
      app: beta-testing-metrics
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF
    
    print_status "Monitoring configurations deployed ✓"
}

# Create workflow templates directory structure
create_directories() {
    print_status "Creating directory structure..."
    
    mkdir -p beta-testing/{week1,week2,week3,week4}
    mkdir -p beta-testing/{configs,scripts,templates,documentation}
    mkdir -p beta-testing/week1/{qe-analysis,integration-setup}
    mkdir -p beta-testing/week2/{environment-design,lifecycle-automation}
    mkdir -p beta-testing/week3/{test-integration,quality-gates}
    mkdir -p beta-testing/week4/{validation,documentation}
    
    print_status "Directory structure created ✓"
}

# Create initial documentation files
create_initial_docs() {
    print_status "Creating initial documentation files..."
    
    # Daily status template
    cat > beta-testing/documentation/daily-status-template.md << 'EOF'
# Beta Testing Daily Status - [Date]

## Progress Summary
- Tasks Completed: [X/Y]
- Blockers: [List any blockers]
- Next Steps: [List next day's priorities]

## Team Updates
- QE Engineer: [Update]
- Dev Team: [Update]
- Platform Team: [Update]

## Metrics
- Environment Provisioning Time: [X minutes]
- Test Execution Success Rate: [X%]
- Integration Status: [Complete/In Progress/Blocked]

## Issues and Risks
- [List any issues or risks]
- [Mitigation strategies]
EOF

    # Weekly progress template
    cat > beta-testing/documentation/weekly-progress-template.md << 'EOF'
# Beta Testing Weekly Progress - Week [X]

## Milestone Status
- [Milestone 1]: [Complete/In Progress/Blocked]
- [Milestone 2]: [Complete/In Progress/Blocked]
- [Milestone 3]: [Complete/In Progress/Blocked]
- [Milestone 4]: [Complete/In Progress/Blocked]

## Key Accomplishments
- [List key accomplishments for the week]

## Challenges and Solutions
- [List challenges faced and solutions implemented]

## Next Week's Focus
- [List priorities for next week]

## Success Metrics
- Environment Setup Time: [Target vs Actual]
- Test Integration: [Target vs Actual]
- Team Satisfaction: [Target vs Actual]
- Platform Reliability: [Target vs Actual]
EOF

    print_status "Initial documentation files created ✓"
}

# Validation function
validate_setup() {
    print_status "Validating setup..."
    
    # Check namespaces
    if ! kubectl get namespace ${BETA_NAMESPACE} &> /dev/null; then
        print_error "Beta namespace not found"
        return 1
    fi
    
    if ! kubectl get namespace ${TEST_ENVIRONMENTS_NAMESPACE} &> /dev/null; then
        print_error "Test environments namespace not found"
        return 1
    fi
    
    # Check ConfigMaps
    if ! kubectl get configmap beta-testing-config -n ${BETA_NAMESPACE} &> /dev/null; then
        print_error "Beta testing config not found"
        return 1
    fi
    
    # Check secrets
    if ! kubectl get secret beta-testing-secrets -n ${BETA_NAMESPACE} &> /dev/null; then
        print_error "Beta testing secrets not found"
        return 1
    fi
    
    print_status "Setup validation passed ✓"
}

# Main execution
main() {
    print_status "Starting beta testing environment setup..."
    
    check_prerequisites
    create_namespaces
    create_rbac
    create_configmaps
    create_secrets
    deploy_monitoring
    create_directories
    create_initial_docs
    validate_setup
    
    print_status "🎉 Beta testing environment setup completed successfully!"
    echo ""
    print_warning "Next steps:"
    echo "1. Update the placeholder secrets with actual values"
    echo "2. Review the created directory structure"
    echo "3. Start with Week 1 tasks: QE framework documentation"
    echo "4. Use the provided templates for daily and weekly reporting"
}

# Run main function
main "$@"
