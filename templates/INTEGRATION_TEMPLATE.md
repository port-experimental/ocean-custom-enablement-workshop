# [Integration Name] Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐⭐ (Beginner/Intermediate)

---

## 1. Use Case

**What problem does this integration solve?**

[Describe the business value and use case - 2-3 sentences]

**Example scenarios:**
- [Scenario 1]
- [Scenario 2]
- [Scenario 3]

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: [Name]
- **API Documentation**: [Link to API docs]
- **Authentication Method**: [Bearer Token / API Key / Basic Auth / OAuth]
- **Base URL**: `https://api.example.com`

**What data will we sync?**
- [Entity 1] - [Brief description]
- [Entity 2] - [Brief description]
- [Entity 3] - [Brief description]

---

## 3. Setup Your Environment

### 3.1 Port Environment Access

**Port Instance**: [Workshop Port URL]  
**Username**: `[workshop-username]`  
**Password**: `[workshop-password]`

> 💡 **Tip**: Log in to Port and verify you can access the workspace.

### 3.2 Kubernetes Cluster Access

**Cluster Name**: `[cluster-name]`  
**Region**: `[region]`

**Connect to the cluster:**

```bash
# Install kubectl (if not already installed)
# macOS:
brew install kubectl

# Linux:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify kubectl is installed
kubectl version --client
```

**Connect to the EKS cluster:**

```bash
# Install AWS CLI (if not already installed)
# macOS:
brew install awscli

# Verify AWS CLI is installed
aws --version

# Configure AWS credentials (if not already configured)
aws configure
# Enter your AWS Access Key ID, Secret Access Key, region, and output format when prompted

# Connect to the EKS cluster
aws eks update-kubeconfig --name [cluster-name] --region [region]

# Verify connection
kubectl get nodes
```

✅ **Checkpoint**: You should see nodes listed. If not, ask for help!

### 3.3 Tool API Credentials

**Get your API token/key:**

1. [Step 1 to get credentials]
2. [Step 2 to get credentials]
3. [Step 3 to get credentials]

**Save your credentials** - you'll need them in step 4.2:
- API Token/Key: `[your-token-here]`

---

## 4. Let's Install a Custom Integration

### 4.1 Create Blueprints in Port

We need to create blueprints before the integration can sync data. Each blueprint defines the structure of entities that will be created.

**Navigate to Blueprints:**

1. Go to your Port workspace
2. Click **"Software Catalog"** → **"Blueprints"**
3. Click **"Create Blueprint"**

**Create Blueprint 1: [Blueprint Name]**

1. Click **"Create Blueprint"**
2. Select **"JSON"** tab
3. Copy and paste the following JSON:

```json
{
  "identifier": "[blueprint_identifier]",
  "title": "[Blueprint Display Name]",
  "icon": "[IconName]",
  "schema": {
    "properties": {
      "property1": {
        "type": "string",
        "title": "Property 1"
      },
      "property2": {
        "type": "string",
        "title": "Property 2"
      }
    }
  }
}
```

4. Click **"Create"**

✅ **Checkpoint**: You should see the blueprint created in your catalog.

**Create Blueprint 2: [Blueprint Name]**

[Repeat for each blueprint]

### 4.2 Install the Integration

**Copy and paste this command** (replace the placeholders with your actual values):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install [integration-name]-integration port-labs/port-ocean \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set integration.identifier=[integration-name]-integration \
  --set integration.type=custom \
  --set integration.version=0.2.11-beta \
  --set integration.config.baseUrl=https://api.example.com \
  --set integration.config.authType=[bearer_token|api_key|basic|none] \
  --set integration.secrets.[token|apiKey|password]=[YOUR_API_TOKEN] \
  --set integration.config.paginationType=[offset|page|cursor|none] \
  --set integration.config.pageSize=100 \
  --set initializePortResources=true \
  --set sendRawDataExamples=true
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Get from Port Settings → Credentials
- `[YOUR_PORT_CLIENT_SECRET]` - Get from Port Settings → Credentials
- `[YOUR_API_TOKEN]` - Your tool API token from step 3.3
- `[integration-name]` - Use a unique name (e.g., `slack`, `zendesk`)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → [integration-name]-integration**

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `[integration-name]-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Add Resource Mapping:**

Click **"Add Resource"** and use this template:

```yaml
resources:
  - kind: /api/v1/endpoint
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: "100"
      data_path: .data
    port:
      entity:
        mappings:
          identifier: .id
          title: .name
          blueprint: '"[blueprint_identifier]"'
          properties:
            property1: .field1
            property2: .field2
```

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/api/v1/users`). Each endpoint is tracked separately in Port's UI.
- `data_path`: **JQ expression to extract the data array** from the API response. Use this when the API wraps data (e.g., `data_path: .results` extracts from `{"results": [...]}`).
- `query_params`: Query parameters to send with the request (e.g., `limit: "100"`).
- `blueprint`: The blueprint identifier (must match what you created in step 4.1).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

**Check Entities in Port:**

1. Go to **"Software Catalog"** → **"Entities"**
2. Filter by your blueprint (e.g., `[blueprint_identifier]`)
3. You should see entities synced from the API

**Check Integration Status:**

Go to **Port UI → Data Sources → [integration-name]-integration** to see the integration status and sync information.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [Tool Name] API documentation and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/api/v1/[another-resource]`
- `/api/v1/[resource]/{id}/[nested-resource]`

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.1
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → [integration-name]-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `data_path`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: Use `data_path` if the API response wraps data in an object (e.g., `data_path: .results`)

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=[integration-name]-integration

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong API token → Verify token is correct
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → [integration-name]-integration
2. Verify blueprints are created correctly
3. Verify `blueprint` identifier in mapping matches blueprint identifier
4. Check `data_path` - it might need adjustment based on API response format (common: `.data`, `.results`, `.items`)

### Issue: Authentication errors

- Verify API token/key is correct
- Check `authType` matches the tool's requirements
- For Basic Auth, ensure username format is correct (some tools use `email/token` format)

### Issue: Pagination not working

- Verify `paginationType` matches the API
- Check `pageSize` is appropriate
- Some APIs need custom parameter names - check API docs

---

## Next Steps

Congratulations! 🎉 You've successfully integrated [Tool Name] with Port.

**What you learned:**
- ✅ How to create blueprints in Port
- ✅ How to install Ocean Custom integration via Helm
- ✅ How to configure resource mappings
- ✅ How to use JQ expressions for data transformation

**Try these next:**
- Integrate another tool using the same process
- Add more properties to your blueprints
- Create relations between entities
- Explore Port's query builder with your new data

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.getport.io/build-your-software-catalog/custom-integration/custom)
- [Port API Documentation](https://docs.getport.io/api-reference)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)
- [Tool Name API Documentation]([API docs link])

---

**Workshop Support**: Questions? Ask in the workshop Slack channel or reach out to facilitators.

