#!/bin/bash

set -e

N8N_API_URL="${N8N_API_URL:-https://n8n.cloud.obeskay.com}"
N8N_API_KEY="${N8N_API_KEY}"
OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"
GITHUB_TOKEN="${GITHUB_TOKEN}"

WORKFLOWS=(
    "openrouter_workflow.json"
        "github_sync_workflow.json"
        )

        validate_json() {
            local file=$1
                if jq empty "$file" 2>/dev/null; then
                        echo "✓ $file valid"
                                return 0
                                    else
                                            echo "✗ $file invalid"
                                                    return 1
                                                        fi
                                                        }

                                                        deploy_workflow() {
                                                            local file=$1
                                                                local name=$(jq -r '.name' "$file")

                                                                    echo "Deploying: $name"

                                                                        if [[ -z "$N8N_API_KEY" ]]; then
                                                                                echo "N8N_API_KEY not set"
                                                                                        return 1
                                                                                            fi

                                                                                                local data=$(jq '{
                                                                                                        name: .name,
                                                                                                                nodes: .nodes,
                                                                                                                        connections: .connections,
                                                                                                                                settings: .settings,
                                                                                                                                        active: false
                                                                                                                                            }' "$file")
                                                                                                                                            
                                                                                                                                                response=$(curl -s -X POST \
                                                                                                                                                        -H "X-N8N-API-KEY: $N8N_API_KEY" \
                                                                                                                                                                -H "Content-Type: application/json" \
                                                                                                                                                                        -d "$data" \
                                                                                                                                                                                "$N8N_API_URL/api/v1/workflows")
                                                                                                                                                                                
                                                                                                                                                                                    if echo "$response" | jq -e '.id' >/dev/null 2>&1; then
                                                                                                                                                                                            local id=$(echo "$response" | jq -r '.id')
                                                                                                                                                                                                    echo "✓ Deployed: $id"
                                                                                                                                                                                                            echo "URL: $N8N_API_URL/workflow/$id"
                                                                                                                                                                                                                    return 0
                                                                                                                                                                                                                        else
                                                                                                                                                                                                                                echo "✗ Failed"
                                                                                                                                                                                                                                        return 1
                                                                                                                                                                                                                                            fi
                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                            echo "Testing workflows..."
                                                                                                                                                                                                                                            for workflow in "${WORKFLOWS[@]}"; do
                                                                                                                                                                                                                                                if [[ -f "$workflow" ]]; then
                                                                                                                                                                                                                                                        validate_json "$workflow"
                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                    echo "✗ $workflow not found"
                                                                                                                                                                                                                                                                        fi
                                                                                                                                                                                                                                                                        done
                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                        echo ""
                                                                                                                                                                                                                                                                        echo "Deploying..."
                                                                                                                                                                                                                                                                        for workflow in "${WORKFLOWS[@]}"; do
                                                                                                                                                                                                                                                                            if [[ -f "$workflow" ]]; then
                                                                                                                                                                                                                                                                                    deploy_workflow "$workflow" || true
                                                                                                                                                                                                                                                                                        fi
                                                                                                                                                                                                                                                                                        done
                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                        echo ""
                                                                                                                                                                                                                                                                                        echo "Done"
