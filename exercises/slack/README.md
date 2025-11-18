# Slack Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐ (Beginner)

---

## 1. Use Case

**What problem does this integration solve?**

Integrating Slack with Port allows you to visualize your team's communication structure, track channel activity, and understand workspace engagement. This is particularly useful for understanding team collaboration patterns and identifying active communication channels.

**Example scenarios:**
- Track which Slack channels are most active
- Monitor team member engagement across workspaces
- Understand workspace structure and organization
- Identify communication patterns and collaboration metrics

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: Slack
- **API Documentation**: [Slack Web API](https://api.slack.com/web)
- **Authentication Method**: Bearer Token (OAuth Token)
- **Base URL**: `https://slack.com/api`

**What data will we sync?**
- **Slack Users** - Team members with profile information and status
- **Slack Channels** - Communication channels with metadata and activity

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

**Request the Slack credentials from Matar** - you'll need the Slack Bot Token (starts with `xoxb-`) for step 4.1.

---

## 4. Let's Install a Custom Integration

### 4.1 Install the Integration

**Copy and paste this command** (replace the placeholders with your credentials):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install slack-integration port-labs/port-ocean \
  --namespace workshop-test \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=slack-integration \
  --set integration.type=custom \
  --set integration.eventListener.type=POLLING \
  --set integration.config.baseUrl=https://slack.com/api \
  --set integration.config.authType=bearer_token \
  --set integration.config.apiToken=[YOUR_SLACK_BOT_TOKEN] \
  --set integration.config.paginationType=cursor \
  --set integration.config.pageSize=200 \
  --set integration.config.paginationParam=cursor \
  --set integration.config.sizeParam=limit \
  --set integration.config.cursorPath=response_metadata.next_cursor \
  --set integration.config.hasMorePath=response_metadata.next_cursor \
  --set initializePortResources=true \
  --set sendRawDataExamples=true \
  --set scheduledResyncInterval=1440
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Port Client ID from step 3.1
- `[YOUR_PORT_CLIENT_SECRET]` - Port Client Secret from step 3.1
- `[YOUR_SLACK_BOT_TOKEN]` - Slack bot token from step 3.3 (starts with `xoxb-`)

**Understanding Ocean Custom-specific configurations:**

- `integration.type=custom` - Ocean Custom integration type
- `integration.config.baseUrl` - Slack API base URL
- `integration.config.authType` - Authentication method (bearer_token)
- `integration.config.apiToken` - Slack bot token (sent as Authorization header)
- `integration.config.paginationType` - Pagination method (cursor-based)
- `integration.config.pageSize` - Items per API call (200)
- `integration.config.paginationParam` - Query param name for cursor (`cursor`)
- `integration.config.sizeParam` - Query param name for page size (`limit`)
- `integration.config.cursorPath` - JQ path to extract next cursor from response
- `integration.config.hasMorePath` - JQ path to check if more pages exist
- `integration.eventListener.type=POLLING` - Polling mode (required for Ocean Custom)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → slack-integration**

### 4.2 Create Blueprints in Port

**Blueprint 1: Ocean Slack User**

```json
{
  "identifier": "ocean_slackUser",
  "description": "A user in the Slack workspace",
  "title": "Ocean Slack User",
  "icon": "Slack",
  "schema": {
    "properties": {
      "real_name": {
        "type": "string",
        "title": "Real Name"
      },
      "display_name": {
        "type": "string",
        "title": "Display Name"
      },
      "email": {
        "type": "string",
        "title": "Email Address"
      },
      "is_admin": {
        "type": "boolean",
        "title": "Is Admin"
      },
      "is_bot": {
        "type": "boolean",
        "title": "Is Bot"
      },
      "status_text": {
        "type": "string",
        "title": "Status Text"
      },
      "status_emoji": {
        "type": "string",
        "title": "Status Emoji"
      },
      "timezone": {
        "type": "string",
        "title": "Timezone"
      },
      "profile_image": {
        "type": "string",
        "title": "Profile Image URL"
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

**Blueprint 2: Ocean Slack Channel**

```json
{
  "identifier": "ocean_slackChannel",
  "description": "A Slack channel for team communication",
  "title": "Ocean Slack Channel",
  "icon": "Slack",
  "schema": {
    "properties": {
      "description": {
        "type": "string",
        "title": "Channel Description"
      },
      "is_private": {
        "type": "boolean",
        "title": "Is Private Channel"
      },
      "member_count": {
        "type": "number",
        "title": "Member Count"
      },
      "created_at": {
        "type": "string",
        "title": "Created At"
      },
      "topic": {
        "type": "string",
        "title": "Channel Topic"
      },
      "purpose": {
        "type": "string",
        "title": "Channel Purpose"
      },
      "is_archived": {
        "type": "boolean",
        "title": "Is Archived"
      },
      "last_activity": {
        "type": "string",
        "title": "Last Activity Timestamp"
      }
    },
    "required": []
  },
  "mirrorProperties": {},
  "calculationProperties": {},
  "aggregationProperties": {},
  "relations": {
    "creator": {
      "target": "ocean_slackUser",
      "required": false,
      "many": false
    },
  }
}
```

✅ **Checkpoint**: You should now have 2 blueprints created: "Ocean Slack User" and "Ocean Slack Channel"

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `slack-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Add Resource Mapping:**

Click **"Add Resource"** or **"Edit Configuration"** and copy-paste this complete YAML block:

```yaml
resources:
  - kind: /api/users.list
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: '100'
      data_path: .members
    port:
      entity:
        mappings:
          identifier: .id
          title: .real_name // .name
          blueprint: '"ocean_slackUser"'
          properties:
            real_name: .real_name
            display_name: .profile.display_name
            email: .profile.email
            is_admin: .is_admin
            is_bot: .is_bot
            status_text: .profile.status_text
            status_emoji: .profile.status_emoji
            timezone: .tz
            profile_image: .profile.image_512
  - kind: /api/conversations.list
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: '100'
        types: public_channel
      data_path: .channels
    port:
      entity:
        mappings:
          identifier: .id
          title: .name
          blueprint: '"ocean_slackChannel"'
          properties:
            description: .purpose.value // ""
            is_private: .is_private
            is_archived: .is_archived
            member_count: .num_members
            created_at: .created
            topic: .topic.value // ""
            purpose: .purpose.value // ""
            last_activity: .updated
          relations:
            creator: .creator
```

**How the mapping translates to HTTP requests:**

Based on the first resource mapping (`/api/users.list`), Port will make this HTTP request:

```http
GET https://slack.com/api/users.list?limit=100
Authorization: Bearer xoxb-your-token-here
```

The Slack API will respond with:
```json
{
  "ok": true,
  "members": [
    {
      "id": "U123456",
      "name": "john.doe",
      "real_name": "John Doe",
      "profile": {
        "display_name": "John",
        "email": "john@example.com",
        "status_text": "Working on Ocean",
        "status_emoji": ":rocket:",
        "image_512": "https://..."
      },
      "is_admin": true,
      "is_bot": false,
      "tz": "America/New_York"
    }
  ],
  "response_metadata": {
    "next_cursor": "dXNlcjpVMTIzNDU2"
  }
}
```

Port then:
1. Uses `data_path: .members` to extract the array of members
2. Applies the JQ mappings to create Port entities (e.g., `identifier: .id`, `title: .real_name // .name`)
3. Uses pagination config to fetch more pages if `response_metadata.next_cursor` exists

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/api/users.list`). Each endpoint is tracked separately in Port's UI.
- `data_path`: **JQ expression to extract the data array** from the API response. 
  
  **Why do we need this?** Slack API responses wrap data in objects. For example:
  ```json
  {
    "ok": true,
    "members": [
      {"id": "U123", "name": "John"},
      {"id": "U456", "name": "Jane"}
    ]
  }
  ```
  We use `data_path: .members` to extract just the array of members.
  
- `query_params`: Query parameters to send with the request (e.g., `limit: "100"`).

**Additional Ocean Custom configurations:**

For advanced configurations like Basic Auth, API Key Auth, Offset/Page Pagination, Dynamic Path Parameters, and Custom Headers, see the [Ocean Custom Integration documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

Go to Port's catalog and check if data is synced in. You should see Slack users and channels appearing as entities.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [Slack Web API documentation](https://api.slack.com/methods) and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/api/users.info` - Get detailed info about a specific user
- `/api/channels.info` - Get detailed info about a specific channel
- `/api/conversations.members` - Get members of a channel

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.1
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → slack-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `data_path`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: Use `data_path` if the API response wraps data in an object (e.g., `data_path: .members`)

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=slack-integration

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong API token → Verify Slack bot token is correct (should start with xoxb-)
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → slack-integration
2. Verify blueprints are created correctly
3. Verify the `blueprint` field in your mapping
4. Check `data_path` - Slack API wraps responses, so you need `data_path: .members` for users, `.channels` for channels, etc.

### Issue: Authentication errors

- Verify Slack bot token is correct (starts with `xoxb-`)
- Check that the bot has the required scopes: `users:read`, `channels:read`, `team:read`
- Ensure the bot is installed to your workspace

### Issue: Missing data

- Slack API has rate limits - if you have many users/channels, pagination may be needed
- Check that your bot has access to the channels you're trying to sync
- Private channels require additional permissions

---

## Next Steps

Congratulations! 🎉 You've successfully integrated Slack with Port.

**What you learned:**
- ✅ How to create blueprints in Port
- ✅ How to install Ocean Custom integration via Helm on EKS
- ✅ How to configure resource mappings with Slack API
- ✅ How to use JQ expressions for data transformation

**Try these next:**
- Integrate another tool using the same process
- Add more properties to your blueprints
- Create relations between entities
- Explore Port's query builder with your Slack data

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.getport.io/build-your-software-catalog/custom-integration/custom)
- [Slack Web API Documentation](https://api.slack.com/web)
- [Slack API Methods](https://api.slack.com/methods)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)

---

**Workshop Support**: Questions? Ask in the workshop Slack channel or reach out to facilitators.

