#!/bin/bash
TOKEN=""
REPO="ci-test-java-project"

# Function to delete all deployment environments
# DOESN'T WORK
# delete_all_environments() {
#     echo "🗑️  Deleting all existing deployment environments..."
    
#     # Get all environments
#     environments=$(curl -s -H "Authorization: Bearer $TOKEN" \
#         -H "Accept: application/json" \
#         "https://api.bitbucket.org/2.0/repositories/admarketplace/$REPO/environments" | \
#         jq -r '.values[].uuid')
    
#     if [[ -z "$environments" ]]; then
#         echo "✅ No existing environments found"
#         return 0
#     fi
    
#     # Delete each environment
#     for env_uuid in $environments; do
#         echo "🗑️  Deleting environment: $env_uuid"
#         response=$(curl -s -w "%{http_code}" -o /dev/null \
#             -X DELETE \
#             -H "Authorization: Bearer $TOKEN" \
#             -H "Accept: application/json" \
#             "https://api.bitbucket.org/2.0/repositories/admarketplace/$REPO/environments/$env_uuid")
        
#         if [[ "$response" == "204" ]]; then
#             echo "✅ Successfully deleted: $env_uuid"
#         else
#             echo "❌ Failed to delete: $env_uuid (HTTP $response)"
#             echo "Response: $response"
#         fi
#     done
# }

# Function to create deployment environment
create_environment() {
    local env_name="$1"
    local env_type="$2"
    local env_rank="$3"
    
    echo "🔧 Creating environment: $env_name"
    #  '{ "type": "deployment_environment", "name": "Dev", "environment_type": {"name": "Test","rank": 1,"type": "deployment_environment_type"} }'
    #  '{ "type": "deployment_environment", "name": "Dev", "environment_type": {"name": "Test","rank": 1,"type": "deployment_environment_type"} }
    response=$(curl -s -w "%{http_code}" -o /tmp/create_env_response.json \
        -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{ \
            \"name\": \"$env_name\",
            \"type\": \"deployment_environment\",
            \"environment_type\": {
                \"type\": \"deployment_environment_type\",
                \"name\": \"$env_type\",
                \"rank\": $env_rank
            }
        }" \
        "https://api.bitbucket.org/2.0/repositories/admarketplace/$REPO/environments")
    
    if [[ "$response" == "201" ]]; then
        echo "✅ Successfully created: $env_name"
        uuid=$(jq -r '.uuid' /tmp/create_env_response.json 2>/dev/null || echo "N/A")
        echo "   UUID: $uuid"
    else
        echo "❌ Failed to create: $env_name (HTTP $response)"
        if [[ -f /tmp/create_env_response.json ]]; then
            echo "   Response: $(cat /tmp/create_env_response.json)"
        fi
    fi
}

# Main execution
echo "🚀 Bitbucket Deployment Environment Reset"
echo "=========================================="

# Step 1: Delete all existing environments
# delete_all_environments

echo ""
echo "🔧 Creating new deployment environments..."

# Step 2: Create new environments according to specs
create_environment "Dev" "Test" 0
create_environment "Stage" "Staging" 1  
create_environment "Prod" "Production" 2

echo ""
echo "✅ Deployment environment reset complete!"

# Cleanup
rm -f /tmp/create_env_response.json