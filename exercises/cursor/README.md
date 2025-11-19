# Cursor Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐⭐ (Intermediate - uses POST requests)

---

## 1. Use Case

**What problem does this integration solve?**

Integrating Cursor with Port allows you to track AI coding assistant usage metrics, monitor team adoption, and understand how your team is leveraging Cursor's AI features. This is particularly useful for measuring productivity gains and optimizing AI tool usage.

**Example scenarios:**
- Track daily Cursor usage metrics across your organization
- Monitor AI code acceptance rates and productivity metrics
- Understand which team members are most active with Cursor
- Measure token consumption and costs

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: Cursor
- **API Documentation**: [Cursor API](https://cursor.com/docs/api)
- **Authentication Method**: Basic Auth (API Key as username, colon ":" as password - Ocean Custom requires non-empty password)
- **Base URL**: `https://api.cursor.com`

**What data will we sync?**
- **Cursor Usage Records** - Daily user-level usage metrics including accepts, rejects, lines added/deleted, and AI model usage (organization extracted from email domain)

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

**Request the Cursor credentials from Matar** - you'll need the Cursor API Key for step 4.1.

---

## 4. Let's Install a Custom Integration

### 4.1 Install the Integration

**Copy and paste this command** (replace the placeholders with your credentials):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install cursor-integration port-labs/port-ocean \
  --namespace workshop-test \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=cursor-integration \
  --set integration.type=custom \
  --set integration.eventListener.type=POLLING \
  --set integration.config.baseUrl=https://api.cursor.com \
  --set integration.config.authType=basic \
  --set integration.config.username=[YOUR_CURSOR_API_KEY] \
  --set integration.config.password=":" \
  --set integration.config.paginationType=none \
  --set initializePortResources=true \
  --set sendRawDataExamples=true \
  --set scheduledResyncInterval=120
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Port Client ID from step 3.1
- `[YOUR_PORT_CLIENT_SECRET]` - Port Client Secret from step 3.1
- `[YOUR_CURSOR_API_KEY]` - Cursor API key from step 3.3

**Understanding Ocean Custom-specific configurations:**

- `integration.type=custom` - Ocean Custom integration type
- `integration.config.baseUrl` - Cursor API base URL
- `integration.config.authType` - Authentication method (basic)
- `integration.config.username` - Cursor API key (used as Basic Auth username)
- `integration.config.password` - Colon ":" (Cursor API accepts empty password, but Ocean Custom requires a non-empty value, so we use ":")
- `integration.config.paginationType` - No pagination (none)
- `integration.eventListener.type=POLLING` - Polling mode (required for Ocean Custom)
- `scheduledResyncInterval=120` - Resync every 120 minutes (2 hours)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → cursor-integration**

### 4.2 Create Blueprints in Port

**Blueprint: Cursor Usage Record**

```json
{
  "identifier": "cursor_usage_record",
  "description": "A daily summary record of Cursor usage for an organization (UTC)",
  "title": "Cursor Usage Record",
  "icon": "Cursor",
  "schema": {
    "properties": {
      "record_date": {
        "type": "string",
        "format": "date-time",
        "title": "Record Date (UTC)"
      },
      "org": {
        "type": "string",
        "title": "Organization"
      },
      "total_accepts": {
        "type": "number",
        "title": "Total Accepts"
      },
      "total_rejects": {
        "type": "number",
        "title": "Total Rejects"
      },
      "total_tabs_shown": {
        "type": "number",
        "title": "Total Tabs Shown"
      },
      "total_tabs_accepted": {
        "type": "number",
        "title": "Total Tabs Accepted"
      },
      "total_lines_added": {
        "type": "number",
        "title": "Total Lines Added"
      },
      "total_lines_deleted": {
        "type": "number",
        "title": "Total Lines Deleted"
      },
      "accepted_lines_added": {
        "type": "number",
        "title": "Accepted Lines Added"
      },
      "accepted_lines_deleted": {
        "type": "number",
        "title": "Accepted Lines Deleted"
      },
      "composer_requests": {
        "type": "number",
        "title": "Composer Requests"
      },
      "chat_requests": {
        "type": "number",
        "title": "Chat Requests"
      },
      "agent_requests": {
        "type": "number",
        "title": "Agent Requests"
      },
      "total_input_tokens": {
        "type": "number",
        "title": "Total Input Tokens"
      },
      "total_output_tokens": {
        "type": "number",
        "title": "Total Output Tokens"
      },
      "total_cache_write_tokens": {
        "type": "number",
        "title": "Total Cache Write Tokens"
      },
      "total_cache_read_tokens": {
        "type": "number",
        "title": "Total Cache Read Tokens"
      },
      "total_cents": {
        "type": "number",
        "title": "Total Cost (cents)"
      },
      "most_used_model": {
        "type": "string",
        "title": "Most Used Model"
      },
      "total_active_users": {
        "type": "number",
        "title": "Total Active Users"
      }
    },
    "required": ["record_date", "org"]
  },
  "mirrorProperties": {},
  "calculationProperties": {
    "acceptance_rate": {
      "title": "Acceptance Rate",
      "description": "Percentage of AI suggestions that were accepted",
      "calculation": "if (.properties.total_accepts + .properties.total_rejects) > 0 then (.properties.total_accepts / (.properties.total_accepts + .properties.total_rejects)) * 100 else 0 end",
      "type": "number",
      "colorized": true,
      "colors": {
        "25": "red",
        "50": "orange",
        "75": "yellow",
        "90": "green"
      }
    }
  },
  "aggregationProperties": {},
  "relations": {}
}
```

✅ **Checkpoint**: You should now have 1 blueprint created: "Cursor Usage Record"

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `cursor-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Add Resource Mapping:**

Click **"Add Resource"** or **"Edit Configuration"** and copy-paste this complete YAML block:

```yaml
resources:
  - kind: /teams/daily-usage-data
    selector:
      query: 'true'
      method: POST
      body: '{"startDate": ((now | floor) - (86400 * 30)) * 1000, "endDate": (now | floor) * 1000}'
      data_path: .data
    port:
      entity:
        mappings:
          identifier: .userId + "@" + .day
          title: .email + " usage " + .day
          blueprint: '"cursor_usage_record"'
          properties:
            record_date: .day + "T00:00:00Z"
            org: (.email | split("@")[1]) // "unknown"
            total_accepts: .totalAccepts // 0
            total_rejects: .totalRejects // 0
            total_tabs_shown: .totalTabsShown // 0
            total_tabs_accepted: .totalTabsAccepted // 0
            total_lines_added: .totalLinesAdded // 0
            total_lines_deleted: .totalLinesDeleted // 0
            accepted_lines_added: .acceptedLinesAdded // 0
            accepted_lines_deleted: .acceptedLinesDeleted // 0
            composer_requests: .composerRequests // 0
            chat_requests: .chatRequests // 0
            agent_requests: .agentRequests // 0
            total_input_tokens: 0
            total_output_tokens: 0
            total_cache_write_tokens: 0
            total_cache_read_tokens: 0
            total_cents: 0
            most_used_model: .mostUsedModel // ""
            total_active_users: 0
```

**How the mapping translates to HTTP requests:**

Based on the resource mapping, Port will make this HTTP request:

```http
POST https://api.cursor.com/teams/daily-usage-data
Authorization: Basic <base64-encoded-api-key:>
Content-Type: application/json

{
  "startDate": 1760961357000,
  "endDate": 1763553357000
}
```

The Cursor API will respond with:
```json
{
  "data": [
    {
      "date": 1763424000000,
      "day": "2025-11-18",
      "userId": "user_Cs774Te78D01KmETGkgN4rdwpn",
      "email": "aaront@getport.io",
      "isActive": true,
      "totalLinesAdded": 150,
      "totalLinesDeleted": 50,
      "acceptedLinesAdded": 120,
      "acceptedLinesDeleted": 45,
      "totalApplies": 10,
      "totalAccepts": 8,
      "totalRejects": 2,
      "totalTabsShown": 200,
      "totalTabsAccepted": 50,
      "composerRequests": 5,
      "chatRequests": 3,
      "agentRequests": 15,
      "mostUsedModel": "claude-4.5-sonnet"
    }
  ]
}
```

Port then:
1. Uses `data_path: .data` to extract the array of usage records
2. Applies the JQ mappings to create Port entities (e.g., `identifier: .userId + "@" + .day`)
3. Maps camelCase API fields to snake_case blueprint properties (e.g., `.totalAccepts` → `total_accepts`)
4. Extracts organization domain from email using `.email | split("@")[1]`

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/teams/daily-usage-data`). Each endpoint is tracked separately in Port's UI.
- `method: POST` - **Cursor uses POST requests** with a JSON body (unlike GET requests in other examples)
- `body`: **JQ expression to generate the request body** - calculates date range dynamically (30 days back from now, which is the API maximum)
- `data_path`: **JQ expression to extract the data array** from the API response
- **Field mapping**: The API returns camelCase fields (e.g., `totalAccepts`), which are mapped to snake_case blueprint properties (e.g., `total_accepts`)
- **Default values**: Uses `//` operator to provide defaults for missing/null values (e.g., `.totalAccepts // 0`)

**Additional Ocean Custom configurations:**

For advanced configurations like API Key Auth, Offset/Page Pagination, Dynamic Path Parameters, and Custom Headers, see the [Ocean Custom Integration documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

Go to Port's catalog and check if data is synced in. You should see Cursor usage records appearing as entities.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [Cursor API documentation](https://cursor.com/docs/api) and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/teams/filtered-usage-events` - Get individual usage events (requires pagination)
- `/analytics/ai-code/commits` - Get commit tracking (requires Enterprise subscription)

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.2
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → cursor-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `method`, `body`, `data_path`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: Cursor uses POST requests with JSON bodies. Use JQ expressions in the `body` field to generate dynamic request bodies. Some endpoints may require pagination handling.

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=cursor-integration -n workshop-test

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong API key → Verify Cursor API key is correct
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → cursor-integration
2. Verify blueprints are created correctly
3. Verify the `blueprint` field in your mapping
4. Check `data_path` - Cursor API wraps responses, so you need `data_path: .data`
5. Verify the `body` JQ expression is generating valid JSON

### Issue: Authentication errors

- Verify Cursor API key is correct
- Check that your API key has access to the organization data you're trying to sync
- Ensure Basic Auth is configured correctly (`authType=basic`, `username` set to API key, `password` set to `":"` - Ocean Custom requires non-empty password)

### Issue: POST request errors

- Verify the `body` JQ expression generates valid JSON
- Check that date calculations in the body are correct
- Some Cursor endpoints require specific date formats

---

## Next Steps

Congratulations! 🎉 You've successfully integrated Cursor with Ocean Custom.

**What you learned:**
- ✅ How to use Basic Authentication with API key as username and colon ":" as password
- ✅ How to configure POST requests with dynamic JSON bodies
- ✅ How to use JQ expressions to generate request bodies and map camelCase to snake_case
- ✅ How to extract organization information from email addresses using JQ
- ✅ How to handle default values in JQ expressions using the `//` operator

**Try these next:**
- Integrate another tool using Ocean Custom (try Claude AI or other exercises)
- Experiment with different date ranges in the request body
- Add more Cursor endpoints to track additional metrics
- Try handling pagination for endpoints that support it

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview)
- [Cursor API Documentation](https://cursor.com/docs/api)
- [Cursor API Reference](https://cursor.com/docs/api#available-apis)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)

