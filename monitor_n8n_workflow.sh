#!/bin/bash

# Monitor OpenRouter Workflow
# Verificación del estado del workflow

WORKFLOW_ID="4lIFCer741OwEzJw"
WEBHOOK_URL="https://n8n.cloud.obeskay.com/webhook/ai-chat"
N8N_BASE_URL="https://n8n.cloud.obeskay.com"

echo "Verificando estado del workflow OpenRouter..."

# Test básico de conectividad
echo "1. Testing webhook endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d '{"message":"health check","model":"openai/gpt-3.5-turbo"}' \
  "$WEBHOOK_URL")

if [ "$response" = "200" ]; then
    echo "Webhook responde correctamente (200 OK)"
elif [ "$response" = "404" ]; then
    echo "Workflow inactivo (404) - Activar en n8n UI"
else
    echo "Error inesperado: HTTP $response"
fi

# Test con diferentes payloads
echo "2. Testing different message types..."

test_cases=(
    '{"message":"Test corto"}'
    '{"message":"Test con modelo específico","model":"openai/gpt-4o-mini"}'
    '{"message":"Test con parámetros","temperature":0.5,"maxTokens":500}'
    '{"message":"Test con system prompt","systemPrompt":"Responde en español"}'
)

for i in "${!test_cases[@]}"; do
    echo "   Test $((i+1)): ${test_cases[i]}"
    status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "${test_cases[i]}" \
        "$WEBHOOK_URL")

    if [ "$status" = "200" ]; then
        echo "   OK"
    else
        echo "   HTTP $status"
    fi
done

# Test de validación de errores
echo "3. Testing error validation..."

error_cases=(
    '{}'
    '{"message":""}'
    '{"message":123}'
    '{"message":"'$(printf 'a%.0s' {1..5000})'"}'
)

error_descriptions=(
    "Sin mensaje"
    "Mensaje vacío"
    "Mensaje no string"
    "Mensaje muy largo"
)

for i in "${!error_cases[@]}"; do
    echo "   Error test $((i+1)): ${error_descriptions[i]}"
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "${error_cases[i]}" \
        "$WEBHOOK_URL")

    if echo "$response" | grep -q '"success":false'; then
        echo "   Error manejado correctamente"
    else
        echo "   Respuesta inesperada"
    fi
done

echo "4. Verificando métricas de rendimiento..."

# Test de latencia
start_time=$(date +%s%N)
curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"message":"Test de latencia"}' \
    "$WEBHOOK_URL" > /dev/null
end_time=$(date +%s%N)

latency=$(( (end_time - start_time) / 1000000 ))
echo "   Latencia del webhook: ${latency}ms"

if [ "$latency" -lt 5000 ]; then
    echo "   Latencia aceptable"
elif [ "$latency" -lt 10000 ]; then
    echo "   Latencia elevada"
else
    echo "   Latencia crítica"
fi

echo ""
echo "RESUMEN DEL DEPLOYMENT:"
echo "Workflow ID: $WORKFLOW_ID"
echo "Endpoint: $WEBHOOK_URL"
echo "Estado: $([ "$response" = "200" ] && echo "ACTIVO" || echo "REQUIERE ACTIVACIÓN")"
echo ""
echo "Para activar:"
echo "1. Ve a: https://n8n.cloud.obeskay.com"
echo "2. Configura credenciales OpenRouter"
echo "3. Activa el workflow con el toggle"
