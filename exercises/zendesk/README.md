# Zendesk Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐ (Beginner)

---

## 1. Use Case

**What problem does this integration solve?**

Integrating Zendesk with Port allows you to visualize your customer support structure, track ticket status, and understand support team organization. This is particularly useful for understanding customer support workflows, ticket volumes, and team performance.

**Example scenarios:**
- Track ticket status and priority across your support team
- Monitor support team organization and user roles
- Understand customer support patterns and ticket volumes
- Identify high-priority issues and their resolution times

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: Zendesk
- **API Documentation**: [Zendesk API](https://developer.zendesk.com/api-reference)
- **Authentication Method**: Basic Auth (Email/Token format)
- **Base URL**: `https://getport.zendesk.com`

**What data will we sync?**
- **Zendesk Users** - Support team members with roles and organization info
- **Zendesk Tickets** - Customer support tickets with status and priority
- **Zendesk Organizations** - Customer organizations

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

**Request the Zendesk credentials from Matar** - you'll need:
- Zendesk Username (format: `email@domain.com/token`)
- Zendesk API Token (password)

---

## 4. Let's Install a Custom Integration

### 4.1 Install the Integration

**Copy and paste this command** (replace the placeholders with your credentials):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install zendesk-integration port-labs/port-ocean \
  --namespace workshop-test \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=zendesk-integration \
  --set integration.type=custom \
  --set integration.eventListener.type=POLLING \
  --set integration.config.baseUrl=https://getport.zendesk.com \
  --set integration.config.authType=basic \
  --set integration.config.username=[YOUR_ZENDESK_USERNAME] \
  --set integration.config.password=[YOUR_ZENDESK_API_TOKEN] \
  --set integration.config.paginationType=cursor \
  --set integration.config.pageSize=100 \
  --set integration.config.paginationParam=page[after] \
  --set integration.config.sizeParam=page[size] \
  --set integration.config.cursorPath=meta.after_cursor \
  --set integration.config.hasMorePath=meta.has_more \
  --set initializePortResources=true \
  --set sendRawDataExamples=true \
  --set scheduledResyncInterval=1440
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Port Client ID from step 3.1
- `[YOUR_PORT_CLIENT_SECRET]` - Port Client Secret from step 3.1
- `[YOUR_ZENDESK_USERNAME]` - Zendesk username (format: `email@domain.com/token`) from step 3.3
- `[YOUR_ZENDESK_API_TOKEN]` - Zendesk API token (password) from step 3.3

**Understanding Ocean Custom-specific configurations:**

- `integration.type=custom` - Ocean Custom integration type
- `integration.config.baseUrl` - Zendesk API base URL
- `integration.config.authType` - Authentication method (basic)
- `integration.config.username` - Zendesk username (email/token format)
- `integration.config.password` - Zendesk API token
- `integration.config.paginationType` - Pagination method (cursor-based)
- `integration.config.pageSize` - Items per API call (100)
- `integration.config.paginationParam` - Query param name for cursor (`page[after]`)
- `integration.config.sizeParam` - Query param name for page size (`page[size]`)
- `integration.config.cursorPath` - JQ path to extract next cursor from response
- `integration.config.hasMorePath` - JQ path to check if more pages exist
- `integration.eventListener.type=POLLING` - Polling mode (required for Ocean Custom)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → zendesk-integration**

### 4.2 Create Blueprints in Port

**Blueprint 1: Zendesk User**

```json
{
  "identifier": "zendesk_user",
  "title": "Zendesk User",
  "icon": "User",
  "schema": {
    "properties": {
      "email": {
        "type": "string",
        "title": "Email",
        "format": "email"
      },
      "role": {
        "type": "string",
        "title": "Role"
      },
      "organization_id": {
        "type": "string",
        "title": "Organization ID"
      },
      "profile_url": {
        "type": "string",
        "title": "Profile Picture",
        "format": "url"
      },
      "active": {
        "type": "boolean",
        "title": "Active"
      },
      "verified": {
        "type": "boolean",
        "title": "Verified"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "aggregationProperties": {},
  "relations": {}
}
```

**Blueprint 2: Zendesk Ticket**

```json
{
  "identifier": "zendesk_ticket",
  "title": "Zendesk Ticket",
  "icon": "Microservice",
  "schema": {
    "properties": {
      "status": {
        "type": "string",
        "title": "Status",
        "enum": ["new", "open", "pending", "hold", "solved", "closed"]
      },
      "priority": {
        "type": "string",
        "title": "Priority",
        "enum": ["low", "normal", "high", "urgent"]
      },
      "requester_id": {
        "type": "string",
        "title": "Requester ID"
      },
      "url": {
        "type": "string",
        "title": "Ticket URL",
        "format": "url"
      },
      "created_at": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "updated_at": {
        "type": "string",
        "title": "Updated At",
        "format": "date-time"
      },
      "description": {
        "type": "string",
        "title": "Description"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "aggregationProperties": {},
  "relations": {}
}
```

**Blueprint 3: Zendesk Organization**

```json
{
  "identifier": "zendesk_organization",
  "title": "Zendesk Organization",
  "icon": "TwoUsers",
  "schema": {
    "properties": {
      "url": {
        "type": "string",
        "title": "URL",
        "format": "url"
      },
      "created_at": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "updated_at": {
        "type": "string",
        "title": "Updated At",
        "format": "date-time"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "aggregationProperties": {},
  "relations": {}
}
```

✅ **Checkpoint**: You should now have 3 blueprints created: "Zendesk User", "Zendesk Ticket", and "Zendesk Organization"

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `zendesk-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Add Resource Mapping:**

Click **"Add Resource"** or **"Edit Configuration"** and copy-paste this complete YAML block:

```yaml
resources:
  - kind: /api/v2/users.json
    selector:
      query: 'true'
      method: GET
      data_path: .users
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .name
          blueprint: '"zendesk_user"'
          properties:
            email: .email
            role: .role
            organization_id: .organization_id | tostring
            profile_url: .photo.content_url
            active: .active
            verified: .verified
  - kind: /api/v2/tickets.json
    selector:
      query: 'true'
      method: GET
      data_path: .tickets
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .subject
          blueprint: '"zendesk_ticket"'
          properties:
            status: .status
            priority: .priority
            requester_id: .requester_id | tostring
            url: .url
            created_at: .created_at
            updated_at: .updated_at
            description: .description
  - kind: /api/v2/organizations.json
    selector:
      query: 'true'
      method: GET
      data_path: .organizations
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .name
          blueprint: '"zendesk_organization"'
          properties:
            url: .url
            created_at: .created_at
            updated_at: .updated_at
```

**How the mapping translates to HTTP requests:**

Based on the first resource mapping (`/api/v2/users.json`), Port will make this HTTP request:

```http
GET https://getport.zendesk.com/api/v2/users.json?page[size]=100
Authorization: Basic <base64-encoded-username:password>
```

The Zendesk API will respond with:
```json
{
  "users": [
    {
      "id": 123456,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin",
      "active": true,
      "verified": true,
      "organization_id": 789,
      "photo": {
        "content_url": "https://..."
      }
    }
  ],
  "meta": {
    "has_more": true,
    "after_cursor": "eyJvZmZzZXQiOjEwMH0="
  }
}
```

Port then:
1. Uses `data_path: .users` to extract the array of users
2. Applies the JQ mappings to create Port entities (e.g., `identifier: .id | tostring`, `title: .name`)
3. Uses pagination config to fetch more pages if `meta.after_cursor` exists

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/api/v2/users.json`). Each endpoint is tracked separately in Port's UI.
- `data_path`: **JQ expression to extract the data array** from the API response. 
  
  **Why do we need this?** Zendesk API responses wrap data in objects. For example:
  ```json
  {
    "users": [...],
    "meta": {...}
  }
  ```
  We use `data_path: .users` to extract just the array of users.
  
- `query_params`: Query parameters to send with the request (Zendesk uses pagination params automatically).

**Additional Ocean Custom configurations:**

For advanced configurations like API Key Auth, Offset/Page Pagination, Dynamic Path Parameters, and Custom Headers, see the [Ocean Custom Integration documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

Go to Port's catalog and check if data is synced in. You should see Zendesk users, tickets, and organizations appearing as entities.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [Zendesk API documentation](https://developer.zendesk.com/api-reference) and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/api/v2/tickets/{ticket_id}/comments.json` - Get comments for a specific ticket (requires path parameters)
- `/api/v2/groups.json` - Get support groups
- `/api/v2/satisfaction_ratings.json` - Get customer satisfaction ratings

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.2
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → zendesk-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `data_path`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: Zendesk uses cursor pagination with `page[after]` and `page[size]` query parameters. The cursor is found in `meta.after_cursor` in the response.

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=zendesk-integration -n workshop-test

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong Zendesk credentials → Verify username format is email@domain.com/token
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → zendesk-integration
2. Verify blueprints are created correctly
3. Verify the `blueprint` field in your mapping
4. Check `data_path` - Zendesk API wraps responses, so you need `data_path: .users` for users, `.tickets` for tickets, `.organizations` for organizations

### Issue: Authentication errors

- Verify Zendesk username format is correct: `email@domain.com/token` (note the `/token` suffix)
- Check that your Zendesk API token is correct
- Ensure your Zendesk account has API access enabled

### Issue: Missing data

- Zendesk API has rate limits - pagination handles this automatically
- Check that your Zendesk account has access to the data you're trying to sync
- Some endpoints may require specific permissions

---

## Next Steps

Congratulations! 🎉 You've successfully integrated Zendesk with Port.

**What you learned:**
- ✅ How to use Basic Authentication with Ocean Custom
- ✅ How to configure cursor pagination with custom parameter names (`page[after]`, `page[size]`)
- ✅ How to map Zendesk API data to Port entities
- ✅ How to use JQ expressions for data transformation

**Try these next:**
- Integrate another tool using the same process
- Add more properties to your blueprints
- Create relations between entities (e.g., tickets → users, tickets → organizations)
- Explore Port's query builder with your Zendesk data

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview)
- [Zendesk API Documentation](https://developer.zendesk.com/api-reference)
- [Zendesk API Reference](https://developer.zendesk.com/api-reference/introduction/)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)

---

**Workshop Support**: Questions? Ask in the workshop Slack channel or reach out to facilitators.

