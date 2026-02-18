#!/bin/bash

# Beta Testing Test Execution Script
# This script executes the integrated test workflows for the beta testing program

set -e

# Default values
APP_NAME="${1:-test-app}"
ENVIRONMENT="${2:-dev}"
TEST_SUITE="${3:-functional,performance,security}"
WORKFLOW_NAMESPACE="beta-testing"
ARGOCD_NAMESPACE="argocd"

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
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if argo CLI is available
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v argo &> /dev/null; then
        print_error "argo CLI is not installed or not in PATH"
        print_status "Please install Argo CLI: https://github.com/argoproj/argo-workflows/releases"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if we can connect to Argo Workflows
    if ! argo list &> /dev/null; then
        print_error "Cannot connect to Argo Workflows"
        print_status "Please ensure Argo Workflows is running and accessible"
        exit 1
    fi
    
    print_status "Prerequisites check passed ✓"
}

# Function to create test environment if it doesn't exist
provision_test_environment() {
    print_status "Provisioning test environment for ${APP_NAME} in ${ENVIRONMENT}..."
    
    # Submit environment provisioning workflow
    ENV_WORKFLOW_NAME="test-env-${APP_NAME}-${ENVIRONMENT}-$(date +%s)"
    
    argo submit --from workflow-template/test-environment-lifecycle \
        -p app-name=${APP_NAME} \
        -p environment=${ENVIRONMENT} \
        -p action=provision \
        -n ${WORKFLOW_NAMESPACE} \
        --name ${ENV_WORKFLOW_NAME} \
        --wait
    
    print_status "Test environment provisioned ✓"
}

# Function to trigger QE test pipelines
trigger_qe_tests() {
    print_status "Triggering QE test pipelines..."
    
    # Split test suite into individual tests
    IFS=',' read -ra TESTS <<< "${TEST_SUITE}"
    
    for test in "${TESTS[@]}"; do
        test=$(echo "$test" | xargs) # trim whitespace
        print_status "Triggering ${test} tests..."
        
        # Submit test workflow for each test type
        TEST_WORKFLOW_NAME="qe-test-${test}-${APP_NAME}-$(date +%s)"
        
        argo submit --from workflow-template/integrated-test-execution \
            -p app-name=${APP_NAME} \
            -p environment=${ENVIRONMENT} \
            -p test-type=${test} \
            -p test-suite=${TEST_SUITE} \
            -n ${WORKFLOW_NAMESPACE} \
            --name ${TEST_WORKFLOW_NAME}
    done
    
    print_status "QE test pipelines triggered ✓"
}

# Function to monitor test execution
monitor_test_execution() {
    print_status "Monitoring test execution..."
    
    local timeout=3600  # 1 hour timeout
    local start_time=$(date +%s)
    
    while true; do
        # Get running workflows for this app and environment
        local running_workflows=$(argo list -n ${WORKFLOW_NAMESPACE} \
            -l app-name=${APP_NAME},environment=${ENVIRONMENT} \
            --status Running | wc -l)
        
        if [[ ${running_workflows} -eq 0 ]]; then
            print_status "All test workflows completed"
            break
        fi
        
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ ${elapsed} -gt ${timeout} ]]; then
            print_warning "Test execution timeout reached"
            break
        fi
        
        print_status "Still running: ${running_workflows} workflows... (${elapsed}s elapsed)"
        sleep 30
    done
}

# Function to collect test results
collect_test_results() {
    print_status "Collecting test results..."
    
    # Create results directory
    local results_dir="beta-testing/results/${APP_NAME}/${ENVIRONMENT}/$(date +%Y%m%d-%H%M%S)"
    mkdir -p ${results_dir}
    
    # Get completed workflows
    local completed_workflows=$(argo list -n ${WORKFLOW_NAMESPACE} \
        -l app-name=${APP_NAME},environment=${ENVIRONMENT} \
        --status Succeeded,Failed)
    
    echo "${completed_workflows}" > ${results_dir}/workflow-summary.txt
    
    # Download artifacts from each workflow
    while IFS= read -r workflow; do
        if [[ -n "${workflow}" ]]; then
            local workflow_name=$(echo "${workflow}" | awk '{print $1}')
            local workflow_status=$(echo "${workflow}" | awk '{print $3}')
            
            print_status "Downloading results from ${workflow_name} (${workflow_status})..."
            
            # Create workflow-specific directory
            mkdir -p ${results_dir}/${workflow_name}
            
            # Download artifacts
            argo get -n ${WORKFLOW_NAMESPACE} ${workflow_name} -o json > ${results_dir}/${workflow_name}/workflow.json
            argo logs -n ${WORKFLOW_NAMESPACE} ${workflow_name} > ${results_dir}/${workflow_name}/logs.txt
            
            # Download test artifacts if they exist
            argo artifact download -n ${WORKFLOW_NAMESPACE} ${workflow_name} -o ${results_dir}/${workflow_name}/artifacts/ 2>/dev/null || true
        fi
    done <<< "${completed_workflows}"
    
    print_status "Test results collected in ${results_dir} ✓"
}

# Function to analyze test results
analyze_test_results() {
    print_status "Analyzing test results..."
    
    local results_dir="beta-testing/results/${APP_NAME}/${ENVIRONMENT}/$(ls -t beta-testing/results/${APP_NAME}/${ENVIRONMENT}/ | head -1)"
    
    # Submit analysis workflow
    ANALYSIS_WORKFLOW_NAME="analyze-results-${APP_NAME}-$(date +%s)"
    
    argo submit --from workflow-template/test-analysis-template \
        -p app-name=${APP_NAME} \
        -p environment=${ENVIRONMENT} \
        -p results-path=${results_dir} \
        -n ${WORKFLOW_NAMESPACE} \
        --name ${ANALYSIS_WORKFLOW_NAME} \
        --wait
    
    # Get analysis results
    argo get -n ${WORKFLOW_NAMESPACE} ${ANALYSIS_WORKFLOW_NAME} -o json > ${results_dir}/analysis.json
    argo logs -n ${WORKFLOW_NAMESPACE} ${ANALYSIS_WORKFLOW_NAME} > ${results_dir}/analysis-logs.txt
    
    print_status "Test results analysis completed ✓"
}

# Function to evaluate quality gates
evaluate_quality_gates() {
    print_status "Evaluating quality gates..."
    
    local results_dir="beta-testing/results/${APP_NAME}/${ENVIRONMENT}/$(ls -t beta-testing/results/${APP_NAME}/${ENVIRONMENT}/ | head -1)"
    
    # Submit quality gate evaluation
    GATE_WORKFLOW_NAME="quality-gate-${APP_NAME}-$(date +%s)"
    
    argo submit --from workflow-template/quality-gate-check \
        -p app-name=${APP_NAME} \
        -p environment=${ENVIRONMENT} \
        -p results-path=${results_dir} \
        -n ${WORKFLOW_NAMESPACE} \
        --name ${GATE_WORKFLOW_NAME} \
        --wait
    
    # Get quality gate results
    local gate_status=$(argo get -n ${WORKFLOW_NAMESPACE} ${GATE_WORKFLOW_NAME} -o json | jq -r '.status.phase')
    
    if [[ "${gate_status}" == "Succeeded" ]]; then
        print_status "🎉 Quality gates passed - Promotion approved!"
        return 0
    else
        print_error "❌ Quality gates failed - Promotion blocked"
        print_status "Check logs for details: argo logs -n ${WORKFLOW_NAMESPACE} ${GATE_WORKFLOW_NAME}"
        return 1
    fi
}

# Function to cleanup test environment
cleanup_test_environment() {
    print_status "Cleaning up test environment..."
    
    # Submit cleanup workflow
    CLEANUP_WORKFLOW_NAME="cleanup-env-${APP_NAME}-${ENVIRONMENT}-$(date +%s)"
    
    argo submit --from workflow-template/test-environment-lifecycle \
        -p app-name=${APP_NAME} \
        -p environment=${ENVIRONMENT} \
        -p action=cleanup \
        -n ${WORKFLOW_NAMESPACE} \
        --name ${CLEANUP_WORKFLOW_NAME} \
        --wait
    
    print_status "Test environment cleanup completed ✓"
}

# Function to generate summary report
generate_summary_report() {
    print_status "Generating summary report..."
    
    local results_dir="beta-testing/results/${APP_NAME}/${ENVIRONMENT}/$(ls -t beta-testing/results/${APP_NAME}/${ENVIRONMENT}/ | head -1)"
    local report_file="${results_dir}/summary-report.md"
    
    cat > ${report_file} << EOF
# Beta Testing Summary Report

## Test Execution Details
- **Application**: ${APP_NAME}
- **Environment**: ${ENVIRONMENT}
- **Test Suite**: ${TEST_SUITE}
- **Execution Date**: $(date)
- **Results Directory**: ${results_dir}

## Workflow Summary
$(cat ${results_dir}/workflow-summary.txt)

## Quality Gate Results
$(if [[ -f "${results_dir}/analysis-logs.txt" ]]; then
    cat "${results_dir}/analysis-logs.txt"
else
    echo "Quality gate analysis not available"
fi)

## Recommendations
- Review detailed logs in the artifacts directory
- Check for any failed tests or performance issues
- Validate that all quality gates passed before proceeding to next environment

## Next Steps
1. If quality gates passed: Consider promotion to next environment
2. If quality gates failed: Address issues and re-run tests
3. Update documentation with lessons learned
EOF

    print_status "Summary report generated: ${report_file} ✓"
}

# Function to display usage
show_usage() {
    echo "Usage: $0 [APP_NAME] [ENVIRONMENT] [TEST_SUITE]"
    echo ""
    echo "Parameters:"
    echo "  APP_NAME    Name of the application to test (default: test-app)"
    echo "  ENVIRONMENT Target environment (default: dev)"
    echo "  TEST_SUITE  Comma-separated list of test types (default: functional,performance,security)"
    echo ""
    echo "Examples:"
    echo "  $0 my-app dev functional"
    echo "  $0 my-service stage functional,performance"
    echo "  $0 production-app prod functional,performance,security"
}

# Main execution function
main() {
    # Parse command line arguments
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    print_header "Beta Testing Test Execution"
    
    print_status "Configuration:"
    print_status "  App Name: ${APP_NAME}"
    print_status "  Environment: ${ENVIRONMENT}"
    print_status "  Test Suite: ${TEST_SUITE}"
    echo ""
    
    check_prerequisites
    
    # Execute test workflow
    provision_test_environment
    trigger_qe_tests
    monitor_test_execution
    collect_test_results
    analyze_test_results
    
    # Evaluate quality gates and handle result
    if evaluate_quality_gates; then
        print_status "✅ Test execution completed successfully - Quality gates passed"
    else
        print_warning "⚠️  Test execution completed - Quality gates failed"
        print_status "Review the detailed results before proceeding"
    fi
    
    generate_summary_report
    
    # Ask if user wants to cleanup
    echo ""
    read -p "Do you want to cleanup the test environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_test_environment
    else
        print_status "Test environment preserved for manual inspection"
    fi
    
    print_status "🎉 Beta testing execution completed!"
}

# Run main function with all arguments
main "$@"
