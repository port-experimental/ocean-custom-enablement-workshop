# Claude AI Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐⭐ (Intermediate - uses custom headers)

---

## 1. Use Case

**What problem does this integration solve?**

Integrating Claude AI with Port allows you to track API usage metrics, monitor costs, and understand how your organization is using Claude's AI models. This is particularly useful for cost optimization, usage monitoring, and understanding model performance across your organization.

**Example scenarios:**
- Track daily Claude API usage and token consumption
- Monitor costs and spending across workspaces
- Understand which models are most used
- Measure API success rates and performance

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: Claude AI (Anthropic)
- **API Documentation**: [Anthropic Admin API](https://docs.anthropic.com/en/api/administration-api)
- **Authentication Method**: Bearer Token (Admin API Key)
- **Base URL**: `https://api.anthropic.com`

**What data will we sync?**
- **Claude Usage Records** - Daily organization-level usage metrics including tokens, requests, and costs

---

## 3. Setup Your Environment

### 3.1 Port Environment Access

**Sign up / Log in to Port** using your email with the workshop suffix:
- Email: `<your-port-email>+ocean-custom-workshop@getport.io`
- Example: If your email is `john@getport.io`, use `john+ocean-custom-workshop@getport.io`

After signing up/logging in, get your Port credentials:
1. Go to **Port Settings** → **Credentials**
2. Copy your **Client ID** and **Client Secret**
3. You'll need these for the Helm installation in step 4.1

> 💡 **Tip**: Verify you can access the workspace after signing up/logging in.

### 3.2 Kubernetes Cluster Access

**Option A: Use Port's EKS Cluster** (Recommended for workshop)

**Cluster Name**: `matar-porternal-ocean-dev`  
**Region**: `us-east-1`  
**AWS Profile**: `se-sandbox`

**Connect to the cluster:**

```bash
# Install kubectl (if not already installed)
brew install kubectl

# Verify kubectl is installed
kubectl version --client

# Install AWS CLI (if not already installed)
brew install awscli

# Verify AWS CLI is installed
aws --version

# Login to AWS SSO
aws sso login --profile se-sandbox

# Connect to the EKS cluster
aws eks update-kubeconfig --name matar-porternal-ocean-dev --region us-east-1 --profile se-sandbox

# Verify connection
kubectl get nodes
```

✅ **Checkpoint**: You should see nodes listed. If not, ask for help!

**Option B: Use Local Minikube** (Alternative for local testing)

**Set up Minikube:**

```bash
# Install minikube (if not already installed)
brew install minikube

# Start minikube
minikube start

# Verify minikube is running
kubectl get nodes

# Create the namespace
kubectl create namespace workshop-test
```

✅ **Checkpoint**: You should see a minikube node listed. If not, check minikube status with `minikube status`.

### 3.3 Tool API Credentials

**Request the Claude AI credentials from Matar** - you'll need the Anthropic Admin API Key (starts with `sk-ant-`) for step 4.1.

---

## 4. Let's Install a Custom Integration

### 4.1 Install the Integration

**Copy and paste this command** (replace the placeholders with your credentials):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install claude-integration port-labs/port-ocean \
  --namespace workshop-test \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=claude-integration \
  --set integration.type=custom \
  --set integration.eventListener.type=POLLING \
  --set integration.config.baseUrl=https://api.anthropic.com \
  --set integration.config.authType=bearer_token \
  --set integration.config.apiToken=[YOUR_ANTHROPIC_API_KEY] \
  --set integration.config.paginationType=none \
  --set initializePortResources=true \
  --set sendRawDataExamples=true \
  --set scheduledResyncInterval=120
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Port Client ID from step 3.1
- `[YOUR_PORT_CLIENT_SECRET]` - Port Client Secret from step 3.1
- `[YOUR_ANTHROPIC_API_KEY]` - Anthropic Admin API key from step 3.3 (starts with `sk-ant-`)

**Understanding Ocean Custom-specific configurations:**

- `integration.type=custom` - Ocean Custom integration type
- `integration.config.baseUrl` - Anthropic API base URL
- `integration.config.authType` - Authentication method (bearer_token)
- `integration.config.apiToken` - Anthropic Admin API key (sent as Authorization header)
- `integration.config.paginationType` - No pagination (none)
- `integration.eventListener.type=POLLING` - Polling mode (required for Ocean Custom)
- `scheduledResyncInterval=120` - Resync every 120 minutes (2 hours)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → claude-integration**

### 4.2 Create Blueprints in Port

**Blueprint: Claude AI Usage Record**

```json
{
  "identifier": "claude_usage_record",
  "description": "A daily summary record of Claude AI API usage for an organization",
  "title": "Claude AI Usage Record",
  "icon": "Anthropic",
  "schema": {
    "properties": {
      "record_date": {
        "type": "string",
        "format": "date-time",
        "title": "Record Date (UTC)"
      },
      "organization_id": {
        "type": "string",
        "title": "Organization ID"
      },
      "organization_name": {
        "type": "string",
        "title": "Organization Name"
      },
      "total_requests": {
        "type": "number",
        "title": "Total Requests"
      },
      "successful_requests": {
        "type": "number",
        "title": "Successful Requests"
      },
      "failed_requests": {
        "type": "number",
        "title": "Failed Requests"
      },
      "total_input_tokens": {
        "type": "number",
        "title": "Total Input Tokens"
      },
      "total_output_tokens": {
        "type": "number",
        "title": "Total Output Tokens"
      },
      "total_cache_read_tokens": {
        "type": "number",
        "title": "Total Cache Read Tokens"
      },
      "total_cache_write_tokens": {
        "type": "number",
        "title": "Total Cache Write Tokens"
      },
      "total_cost_usd": {
        "type": "number",
        "title": "Total Cost (USD)"
      },
      "most_used_model": {
        "type": "string",
        "title": "Most Used Model"
      }
    },
    "required": ["record_date", "organization_id"]
  },
  "mirrorProperties": {},
  "calculationProperties": {
    "success_rate": {
      "title": "Success Rate",
      "description": "Percentage of successful API requests",
      "calculation": "if .properties.total_requests > 0 then (.properties.successful_requests / .properties.total_requests) * 100 else 0 end",
      "type": "number",
      "colorized": true,
      "colors": {
        "80": "red",
        "90": "orange",
        "95": "yellow",
        "98": "green"
      }
    }
  },
  "aggregationProperties": {},
  "relations": {}
}
```

✅ **Checkpoint**: You should now have 1 blueprint created: "Claude AI Usage Record"

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `claude-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Important: Add Custom Headers First**

Before adding the resource mapping, you need to configure custom HTTP headers. Go to **Advanced Settings → Headers** and add:
- `anthropic-version: 2023-06-01`
- `anthropic-beta: admin-1`

These headers are required for Anthropic Admin API endpoints.

**Add Resource Mapping:**

Click **"Add Resource"** or **"Edit Configuration"** and copy-paste this complete YAML block:

```yaml
resources:
  - kind: /v1/organizations/usage_report/messages
    selector:
      query: 'true'
      method: GET
      query_params:
        starting_at: '((now | floor) - (86400 * 30)) | strftime("%Y-%m-%dT00:00:00Z")'
        ending_at: '(now | floor) | strftime("%Y-%m-%dT00:00:00Z")'
        bucket_width: "1d"
      data_path: '.data[].results[]'
    port:
      entity:
        mappings:
          identifier: '((.date // .starting_at // "unknown") | tostring) + "@org"'
          title: '"Claude Usage - " + ((.date // .starting_at // "unknown") | tostring)'
          blueprint: '"claude_usage_record"'
          properties:
            record_date: (.date // .starting_at // "")
            organization_id: .organization_id // ""
            organization_name: .organization_name // ""
            total_requests: .requests // 0
            successful_requests: .successful_requests // 0
            failed_requests: (.failed_requests // 0)
            total_input_tokens: .input_tokens // 0
            total_output_tokens: .output_tokens // 0
            total_cache_read_tokens: .cache_read_input_tokens // 0
            total_cache_write_tokens: .cache_write_input_tokens // 0
            total_cost_usd: .cost_usd // 0
```

**How the mapping translates to HTTP requests:**

Based on the resource mapping, Port will make this HTTP request:

```http
GET https://api.anthropic.com/v1/organizations/usage_report/messages?starting_at=2024-01-01T00:00:00Z&ending_at=2024-01-31T00:00:00Z&bucket_width=1d
Authorization: Bearer sk-ant-api03-...
anthropic-version: 2023-06-01
anthropic-beta: admin-1
```

The Anthropic API will respond with:
```json
{
  "data": [
    {
      "starting_at": "2024-01-15T00:00:00Z",
      "ending_at": "2024-01-16T00:00:00Z",
      "results": [
        {
          "date": "2024-01-15",
          "organization_id": "org-123",
          "organization_name": "My Org",
          "requests": 1000,
          "successful_requests": 980,
          "failed_requests": 20,
          "input_tokens": 500000,
          "output_tokens": 300000,
          "cost_usd": 15.50
        }
      ]
    }
  ]
}
```

Port then:
1. Uses `data_path: '.data[].results[]'` to extract the array from nested buckets
2. Applies the JQ mappings to create Port entities
3. Uses JQ expressions in `query_params` to generate dynamic date ranges

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/v1/organizations/usage_report/messages`). Each endpoint is tracked separately in Port's UI.
- `query_params`: **JQ expressions to generate query parameters** - dynamically calculates date ranges
- `data_path`: **JQ expression to extract nested arrays** - Anthropic returns data in buckets with nested results arrays
- **Custom Headers**: Required for Anthropic Admin API - must be configured in Advanced Settings

**Additional Ocean Custom configurations:**

For advanced configurations like Basic Auth, API Key Auth, Offset/Page Pagination, Dynamic Path Parameters, and Custom Headers, see the [Ocean Custom Integration documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

Go to Port's catalog and check if data is synced in. You should see Claude AI usage records appearing as entities.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [Anthropic Admin API documentation](https://docs.anthropic.com/en/api/administration-api) and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/v1/organizations/cost_report` - Get cost tracking data
- `/v1/organizations/usage_report/messages` with `group_by[]=workspace_id` - Get workspace-level metrics
- `/v1/organizations/usage_report/claude_code` - Get Claude Code analytics (requires Claude Code access)

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.2
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → claude-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `query_params`, `data_path`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: Anthropic Admin API requires custom headers (`anthropic-version` and `anthropic-beta`). Make sure these are configured in Advanced Settings. The API uses nested response structures, so `data_path` needs to navigate through buckets and results arrays.

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=claude-integration -n workshop-test

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong API key → Verify Anthropic Admin API key is correct (should start with sk-ant-)
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → claude-integration
2. Verify blueprints are created correctly
3. Verify the `blueprint` field in your mapping
4. Check `data_path` - Anthropic API uses nested structures, so you need `data_path: '.data[].results[]'`
5. **Verify custom headers are configured** - Go to Advanced Settings → Headers and ensure `anthropic-version` and `anthropic-beta` are set

### Issue: Authentication errors

- Verify Anthropic Admin API key is correct (starts with `sk-ant-`)
- Check that your API key has Admin API access (not just regular API access)
- Ensure the API key has permissions to read usage data

### Issue: API errors (400/401)

- **Most common**: Missing custom headers - ensure `anthropic-version: 2023-06-01` and `anthropic-beta: admin-1` are configured
- Verify date format in query parameters matches Anthropic's expected format
- Check that your API key has access to the Admin API endpoints

---

## Next Steps

Congratulations! 🎉 You've successfully integrated Claude AI with Ocean Custom.

**What you learned:**
- ✅ How to configure custom HTTP headers for API requirements
- ✅ How to use JQ expressions in query parameters for dynamic values
- ✅ How to map nested API responses using complex `data_path` expressions
- ✅ How to handle Anthropic Admin API's bucket-based response structure

**Try these next:**
- Integrate another tool using Ocean Custom (try Cursor or other exercises)
- Experiment with different date ranges and grouping options
- Add more Anthropic endpoints (cost reports, workspace metrics)
- Try grouping usage data by workspace or model

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview)
- [Anthropic Admin API Documentation](https://docs.anthropic.com/en/api/administration-api)
- [Anthropic API Reference](https://docs.anthropic.com/en/api/getting-started-with-the-api)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)

