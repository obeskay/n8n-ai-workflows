#!/bin/bash

# Test OpenRouter API
# Verifica credenciales antes del deployment

echo "Testing OpenRouter API..."

# Verificar si existe variable de entorno
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "OPENROUTER_API_KEY no configurada"
        echo "Configúrala con: export OPENROUTER_API_KEY='sk-or-v1-...'"
            read -p "Ingresa tu API key (opcional): " api_key
                if [ -n "$api_key" ]; then
                        OPENROUTER_API_KEY="$api_key"
                            else
                                    echo "No se puede continuar sin API key"
                                            exit 1
                                                fi
                                                fi

                                                # Test básico de autenticación
                                                echo "1. Testing authentication..."
                                                auth_response=$(curl -s -w "%{http_code}" -o /tmp/openrouter_test.json \
                                                    -X POST "https://openrouter.ai/api/v1/chat/completions" \
                                                        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
                                                            -H "Content-Type: application/json" \
                                                                -d '{
                                                                        "model": "openai/gpt-3.5-turbo",
                                                                                "messages": [{"role": "user", "content": "Test"}],
                                                                                        "max_tokens": 10
                                                                                            }')

                                                                                            if [ "$auth_response" = "200" ]; then
                                                                                                echo "Autenticación exitosa"

                                                                                                    # Verificar respuesta
                                                                                                        if [ -f /tmp/openrouter_test.json ]; then
                                                                                                                echo "Respuesta de OpenRouter:"
                                                                                                                        cat /tmp/openrouter_test.json | jq '.' 2>/dev/null || cat /tmp/openrouter_test.json
                                                                                                                                rm -f /tmp/openrouter_test.json
                                                                                                                                    fi
                                                                                                                                    
                                                                                                                                    elif [ "$auth_response" = "401" ]; then
                                                                                                                                        echo "Error de autenticación - Verifica tu API key"
                                                                                                                                            exit 1
                                                                                                                                            elif [ "$auth_response" = "429" ]; then
                                                                                                                                                echo "Rate limit - Intenta de nuevo en unos minutos"
                                                                                                                                                    exit 1
                                                                                                                                                    else
                                                                                                                                                        echo "Error inesperado: HTTP $auth_response"
                                                                                                                                                            exit 1
                                                                                                                                                            fi
                                                                                                                                                            
                                                                                                                                                            # Test de modelos disponibles
                                                                                                                                                            echo "2. Checking available models..."
                                                                                                                                                            models_response=$(curl -s -w "%{http_code}" -o /tmp/models.json \
                                                                                                                                                                -X GET "https://openrouter.ai/api/v1/models" \
                                                                                                                                                                    -H "Authorization: Bearer $OPENROUTER_API_KEY")
                                                                                                                                                                    
                                                                                                                                                                    if [ "$models_response" = "200" ]; then
                                                                                                                                                                        echo "Modelos disponibles obtenidos"
                                                                                                                                                                            echo "Modelos recomendados:"
                                                                                                                                                                            
                                                                                                                                                                                if command -v jq >/dev/null 2>&1; then
                                                                                                                                                                                        cat /tmp/models.json | jq -r '.data[] | select(.id | contains("openai/gpt-3.5") or contains("openai/gpt-4o") or contains("anthropic/claude")) | "  - " + .id + " (" + .name + ")"' | head -10
                                                                                                                                                                                            else
                                                                                                                                                                                                    echo "  - openai/gpt-3.5-turbo (recomendado para costo)"
                                                                                                                                                                                                            echo "  - openai/gpt-4o-mini (balance precio/rendimiento)"
                                                                                                                                                                                                                    echo "  - openai/gpt-4o (mejor calidad)"
                                                                                                                                                                                                                            echo "  - anthropic/claude-3.5-sonnet (excelente para código)"
                                                                                                                                                                                                                                fi
                                                                                                                                                                                                                                    rm -f /tmp/models.json
                                                                                                                                                                                                                                    fi
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                    echo ""
                                                                                                                                                                                                                                    echo "OpenRouter configurado correctamente"
                                                                                                                                                                                                                                    echo "Próximo paso: Configura estas credenciales en n8n"
                                                                                                                                                                                                                                    echo "   1. Ve a n8n → Credentials → Create New → OpenRouter API"
                                                                                                                                                                                                                                    echo "   2. API Key: $OPENROUTER_API_KEY"
                                                                                                                                                                                                                                    echo "   3. Activa el workflow ID: 4lIFCer741OwEzJw"
