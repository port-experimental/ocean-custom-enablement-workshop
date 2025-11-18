# Learned Configuration from Working Integrations

## Key Findings from Existing Installations

### 1. Authentication Configuration

**Bearer Token (Slack, HubSpot):**
```yaml
integration:
  config:
    authType: bearer_token
    apiToken: <token>  # NOT in secrets.apiToken
```

**Basic Auth (Zendesk):**
```yaml
integration:
  config:
    authType: basic
    username: <username>  # NOT in secrets.username
    password: <password>   # NOT in secrets.password
```

### 2. Chart and Image

- **Chart**: `port-labs/port-ocean`
- **Image**: Automatically set to `ghcr.io/port-labs/port-ocean-custom:latest` when `integration.type: custom`
- **Chart Version**: Currently using `0.9.10` or `0.10.0`

### 3. Common Configuration Values

```yaml
initializePortResources: true
sendRawDataExamples: true
scheduledResyncInterval: 1440  # Optional: 1440 = 24 hours
integration:
  type: custom
  identifier: <integration-name>-integration
port:
  baseUrl: https://api.getport.io
  clientId: <port-client-id>
  clientSecret: <port-client-secret>
```

### 4. Pagination Configuration

**Cursor Pagination (Slack, Zendesk, HubSpot):**
```yaml
integration:
  config:
    paginationType: cursor
    pageSize: 100
    paginationParam: <param-name>  # e.g., "cursor", "after", "page[after]"
    sizeParam: <size-param>         # e.g., "limit", "page[size]"
    cursorPath: <json-path>         # e.g., "response_metadata.next_cursor"
    hasMorePath: <json-path>        # e.g., "response_metadata.next_cursor"
```

### 5. Resource Mappings

For HubSpot, resource mappings are embedded in the config:
```yaml
integration:
  config:
    resources: |
      createMissingRelatedEntities: true
      deleteDependentEntities: true
      resources:
        - kind: /api/endpoint
          selector:
            ...
```

### 6. Correct Helm Install Command Format

Based on working installations:

```bash
helm install <integration-name> port-labs/port-ocean \
  --namespace <namespace> \
  --set port.clientId=<PORT_CLIENT_ID> \
  --set port.clientSecret=<PORT_CLIENT_SECRET> \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=<integration-name>-integration \
  --set integration.type=custom \
  --set integration.config.baseUrl=<API_BASE_URL> \
  --set integration.config.authType=<bearer_token|basic|api_key|none> \
  --set integration.config.apiToken=<TOKEN> \
  --set integration.config.paginationType=<cursor|offset|page|none> \
  --set integration.config.pageSize=100 \
  --set initializePortResources=true \
  --set sendRawDataExamples=true
```

### 7. Important Notes

- **Secrets go in `integration.config.*` NOT `integration.secrets.*`** (based on working configs)
- For bearer token: use `integration.config.apiToken`
- For basic auth: use `integration.config.username` and `integration.config.password`
- Chart automatically uses `port-ocean-custom` image when `type: custom`
- `scheduledResyncInterval` is optional (in minutes, e.g., 1440 = 24 hours)

