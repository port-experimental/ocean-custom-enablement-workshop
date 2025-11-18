#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="workshop-test"
PORT_API_URL="https://api.getport.io"
PORT_CLIENT_ID="${PORT_CLIENT_ID:-y9em2haVu0WMdSQZKrU01u6nLpg4PXTu}"
PORT_CLIENT_SECRET="${PORT_CLIENT_SECRET:-4vcZ3lacigc7krmuSRA4IWPifMHWxYa1gRoQ2h4Ed0YsuWYwjHc6rUY9SoA8uUEZ}"

# Integration identifiers (matching Helm release names)
INTEGRATIONS=(
    "slack-integration"
    "zendesk-integration"
    "hubspot-integration"
    "cursor-integration"
    "claude-integration"
)

# Blueprint identifiers (extracted from blueprints.json files)
BLUEPRINTS=(
    # Slack
    "ocean_slackUser"
    "ocean_slackChannel"
    # Zendesk
    "zendesk_organization"
    "zendesk_user"
    "zendesk_ticket"
    "zendesk_comment"
    # HubSpot
    "ocean_hubspotContact"
    "ocean_hubspotCompany"
    "ocean_hubspotDeal"
    "ocean_hubspotFeatureRequest"
    # Cursor
    "cursor_usage_record"
    # Claude AI
    "claude_usage_record"
)

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get Port access token
get_port_token() {
    print_info "Getting Port access token..."
    local response=$(curl -s -X POST "${PORT_API_URL}/auth/access_token" \
        -H "Content-Type: application/json" \
        -d "{\"clientId\":\"${PORT_CLIENT_ID}\",\"clientSecret\":\"${PORT_CLIENT_SECRET}\"}")
    
    local token=$(echo "$response" | jq -r '.accessToken // empty')
    
    if [ -z "$token" ] || [ "$token" = "null" ]; then
        print_error "Failed to get Port access token"
        echo "Response: $response"
        exit 1
    fi
    
    echo "$token"
}

# Function to delete Helm releases
delete_k8s_integrations() {
    print_info "Deleting Kubernetes integrations..."
    
    for integration in "${INTEGRATIONS[@]}"; do
        if helm list -n "$NAMESPACE" | grep -q "^${integration}"; then
            print_info "Uninstalling Helm release: ${integration}"
            helm uninstall "$integration" -n "$NAMESPACE" || print_warning "Failed to uninstall ${integration}"
        else
            print_warning "Helm release ${integration} not found, skipping..."
        fi
    done
    
    print_info "Kubernetes cleanup completed"
}

# Function to delete Port integrations
delete_port_integrations() {
    local token=$1
    print_info "Deleting Port integrations..."
    
    for integration in "${INTEGRATIONS[@]}"; do
        print_info "Deleting integration: ${integration}"
        local response=$(curl -s -w "\n%{http_code}" -X DELETE \
            "${PORT_API_URL}/integrations/${integration}" \
            -H "Authorization: Bearer ${token}")
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "204" ]; then
            print_info "Successfully deleted integration: ${integration}"
        elif [ "$http_code" = "404" ]; then
            print_warning "Integration ${integration} not found, skipping..."
        else
            print_error "Failed to delete integration ${integration} (HTTP ${http_code})"
            echo "Response: $body"
        fi
    done
    
    print_info "Port integrations cleanup completed"
}

# Function to delete Port blueprints
delete_port_blueprints() {
    local token=$1
    print_info "Deleting Port blueprints..."
    
    for blueprint in "${BLUEPRINTS[@]}"; do
        print_info "Deleting blueprint: ${blueprint}"
        
        # Try to delete with entities first
        local response=$(curl -s -w "\n%{http_code}" -X DELETE \
            "${PORT_API_URL}/blueprints/${blueprint}/all-entities?delete_blueprint=true" \
            -H "Authorization: Bearer ${token}")
        
        local http_code=$(echo "$response" | tail -n1)
        local body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "202" ]; then
            local migration_id=$(echo "$body" | jq -r '.migrationId // empty')
            if [ -n "$migration_id" ] && [ "$migration_id" != "null" ]; then
                print_info "Blueprint ${blueprint} deletion started (migration: ${migration_id})"
            else
                print_info "Successfully deleted blueprint: ${blueprint}"
            fi
        elif [ "$http_code" = "404" ]; then
            print_warning "Blueprint ${blueprint} not found, skipping..."
        else
            # Try without deleting entities
            print_warning "Failed to delete blueprint ${blueprint} with entities (HTTP ${http_code}), trying without entities..."
            local response2=$(curl -s -w "\n%{http_code}" -X DELETE \
                "${PORT_API_URL}/blueprints/${blueprint}" \
                -H "Authorization: Bearer ${token}")
            
            local http_code2=$(echo "$response2" | tail -n1)
            if [ "$http_code2" = "200" ] || [ "$http_code2" = "204" ]; then
                print_info "Successfully deleted blueprint: ${blueprint}"
            elif [ "$http_code2" = "404" ]; then
                print_warning "Blueprint ${blueprint} not found, skipping..."
            else
                print_error "Failed to delete blueprint ${blueprint} (HTTP ${http_code2})"
            fi
        fi
    done
    
    print_info "Port blueprints cleanup completed"
}

# Main execution
main() {
    print_info "Starting workshop cleanup..."
    print_warning "This will delete:"
    print_warning "  - Kubernetes integrations (Helm releases)"
    print_warning "  - Port integrations"
    print_warning "  - Port blueprints (with all entities)"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Cleanup cancelled"
        exit 0
    fi
    
    # Step 1: Delete K8s integrations
    delete_k8s_integrations
    
    # Step 2: Get Port token
    PORT_TOKEN=$(get_port_token)
    
    # Step 3: Delete Port integrations
    delete_port_integrations "$PORT_TOKEN"
    
    # Step 4: Delete Port blueprints
    delete_port_blueprints "$PORT_TOKEN"
    
    print_info "Workshop cleanup completed! 🎉"
}

# Run main function
main

