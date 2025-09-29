# n8n Workflows

Workflows para n8n con OpenRouter y GitHub sync.

## Setup

### OpenRouter

1. Consigue tu API key en [openrouter.ai](https://openrouter.ai)
2. 2. Importa `openrouter_workflow.json` en n8n
   3. 3. Configura las credenciales:
      4.    - Type: Header Auth
            -    - Name: Authorization
                 -    - Value: Bearer YOUR_KEY
                  
                      - ### GitHub Sync
                  
                      - 1. Crea un personal access token en GitHub
                        2. 2. Importa `github_sync_workflow.json`
                           3. 3. Configura las credenciales de GitHub y n8n
                             
                              4. ## Endpoints
                             
                              5. ```bash
                                 # OpenRouter
                                 POST https://n8n.cloud.obeskay.com/webhook/chat
                                 {
                                   "message": "tu mensaje",
                                   "model": "openai/gpt-3.5-turbo"
                                 }

                                 # GitHub sync manual
                                 POST https://n8n.cloud.obeskay.com/webhook/github-sync
                                 {
                                   "trigger": "manual"
                                 }
                                 ```

                                 ## Deploy

                                 ```bash
                                 chmod +x deploy_workflows.sh
                                 ./deploy_workflows.sh
                                 ```

                                 ## Estructura

                                 ```
                                 ├── openrouter_workflow.json     # API de chat
                                 ├── github_sync_workflow.json    # Sincronización con GitHub
                                 ├── deploy_workflows.sh          # Script de deployment
                                 └── test_openrouter_api.sh      # Test de credenciales
                                 ```

                                 ## Tests

                                 ```bash
                                 # Probar OpenRouter API
                                 ./test_openrouter_api.sh

                                 # Monitor de workflows
                                 ./monitor_n8n_workflow.sh
                                 ```
