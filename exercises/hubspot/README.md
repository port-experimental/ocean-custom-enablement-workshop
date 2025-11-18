# HubSpot Integration Workshop

**Estimated Time**: 60 minutes  
**Difficulty**: ⭐⭐ (Beginner)

---

## 1. Use Case

**What problem does this integration solve?**

Integrating HubSpot with Port allows you to visualize your CRM data, track sales pipeline, and connect customer relationships to your software catalog. This is particularly useful for understanding customer context, tracking deals, and managing feature requests.

**Example scenarios:**
- Track sales pipeline and deal stages in your developer portal
- Connect customer contacts and companies to your services
- Manage product feature requests with customer voting
- Understand customer relationships and their engagement with your products

---

## 2. Tool Overview

**Which tool will you integrate?**

- **Tool Name**: HubSpot
- **API Documentation**: [HubSpot API](https://developers.hubspot.com/docs/api/overview)
- **Authentication Method**: Bearer Token (Private App Access Token)
- **Base URL**: `https://api.hubapi.com`

**What data will we sync?**
- **HubSpot Contacts** - CRM contacts with email and lifecycle stage
- **HubSpot Companies** - Organizations with industry and revenue data
- **HubSpot Deals** - Sales opportunities with pipeline stages

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

**Request the HubSpot credentials from Matar** - you'll need the HubSpot API Token (starts with `pat-`) for step 4.1.

---

## 4. Let's Install a Custom Integration

### 4.1 Install the Integration

**Copy and paste this command** (replace the placeholders with your credentials):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts && \
helm repo update && \
helm install hubspot-integration port-labs/port-ocean \
  --namespace workshop-test \
  --set port.clientId=[YOUR_PORT_CLIENT_ID] \
  --set port.clientSecret=[YOUR_PORT_CLIENT_SECRET] \
  --set port.baseUrl=https://api.getport.io \
  --set integration.identifier=hubspot-integration \
  --set integration.type=custom \
  --set integration.eventListener.type=POLLING \
  --set integration.config.baseUrl=https://api.hubapi.com \
  --set integration.config.authType=bearer_token \
  --set integration.config.apiToken=[YOUR_HUBSPOT_API_TOKEN] \
  --set integration.config.paginationType=cursor \
  --set integration.config.pageSize=100 \
  --set integration.config.paginationParam=after \
  --set integration.config.sizeParam=limit \
  --set integration.config.cursorPath=paging.next.after \
  --set integration.config.hasMorePath=paging.next \
  --set initializePortResources=true \
  --set sendRawDataExamples=true \
  --set scheduledResyncInterval=1440
```

**Replace these values:**
- `[YOUR_PORT_CLIENT_ID]` - Port Client ID from step 3.1
- `[YOUR_PORT_CLIENT_SECRET]` - Port Client Secret from step 3.1
- `[YOUR_HUBSPOT_API_TOKEN]` - HubSpot API token from step 3.3 (starts with `pat-`)

**Understanding Ocean Custom-specific configurations:**

- `integration.type=custom` - Ocean Custom integration type
- `integration.config.baseUrl` - HubSpot API base URL
- `integration.config.authType` - Authentication method (bearer_token)
- `integration.config.apiToken` - HubSpot API token (sent as Authorization header)
- `integration.config.paginationType` - Pagination method (cursor-based)
- `integration.config.pageSize` - Items per API call (100)
- `integration.config.paginationParam` - Query param name for cursor (`after`)
- `integration.config.sizeParam` - Query param name for page size (`limit`)
- `integration.config.cursorPath` - JQ path to extract next cursor from response
- `integration.config.hasMorePath` - JQ path to check if more pages exist
- `integration.eventListener.type=POLLING` - Polling mode (required for Ocean Custom)

✅ **Checkpoint**: Verify the installation by going to **Port UI → Data Sources → hubspot-integration**

### 4.2 Create Blueprints in Port

**Blueprint 1: Ocean HubSpot Contact**

```json
{
  "identifier": "ocean_hubspotContact",
  "title": "Ocean HubSpot Contact",
  "icon": "User",
  "schema": {
    "properties": {
      "email": {
        "type": "string",
        "title": "Email",
        "format": "email"
      },
      "firstname": {
        "type": "string",
        "title": "First Name"
      },
      "lastname": {
        "type": "string",
        "title": "Last Name"
      },
      "phone": {
        "type": "string",
        "title": "Phone"
      },
      "lifecyclestage": {
        "type": "string",
        "title": "Lifecycle Stage"
      },
      "createdAt": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "updatedAt": {
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
  "relations": {
    "company": {
      "target": "ocean_hubspotCompany",
      "required": false,
      "many": false
    }
  }
}
```

**Blueprint 2: Ocean HubSpot Company**

```json
{
  "identifier": "ocean_hubspotCompany",
  "title": "Ocean HubSpot Company",
  "icon": "TwoUsers",
  "schema": {
    "properties": {
      "name": {
        "type": "string",
        "title": "Company Name"
      },
      "domain": {
        "type": "string",
        "title": "Domain"
      },
      "industry": {
        "type": "string",
        "title": "Industry"
      },
      "city": {
        "type": "string",
        "title": "City"
      },
      "state": {
        "type": "string",
        "title": "State"
      },
      "country": {
        "type": "string",
        "title": "Country"
      },
      "numberOfEmployees": {
        "type": "number",
        "title": "Number of Employees"
      },
      "annualRevenue": {
        "type": "number",
        "title": "Annual Revenue"
      },
      "createdAt": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "updatedAt": {
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

**Blueprint 3: Ocean HubSpot Deal**

```json
{
  "identifier": "ocean_hubspotDeal",
  "title": "Ocean HubSpot Deal",
  "icon": "Microservice",
  "schema": {
    "properties": {
      "dealname": {
        "type": "string",
        "title": "Deal Name"
      },
      "amount": {
        "type": "string",
        "title": "Amount"
      },
      "dealstage": {
        "type": "string",
        "title": "Deal Stage"
      },
      "pipeline": {
        "type": "string",
        "title": "Pipeline"
      },
      "closedate": {
        "type": "string",
        "title": "Close Date"
      },
      "probability": {
        "type": "string",
        "title": "Probability"
      },
      "dealtype": {
        "type": "string",
        "title": "Deal Type"
      },
      "createdAt": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "updatedAt": {
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
  "relations": {
    "companies": {
      "target": "ocean_hubspotCompany",
      "required": false,
      "many": true
    },
    "contacts": {
      "target": "ocean_hubspotContact",
      "required": false,
      "many": true
    }
  }
}
```

✅ **Checkpoint**: You should now have 3 blueprints created: "Ocean HubSpot Contact", "Ocean HubSpot Company", and "Ocean HubSpot Deal"

---

## 5. Add Resource Mapping

Now we need to tell the integration which API endpoints to call and how to map the data to Port entities.

**Navigate to Integration Configuration:**

1. In Port, go to **"Data Sources"**
2. Find your integration: `hubspot-integration`
3. Click **"Configure"** or **"Edit Configuration"**

**Add Resource Mapping:**

Click **"Add Resource"** or **"Edit Configuration"** and copy-paste this complete YAML block:

```yaml
resources:
  - kind: /crm/v3/objects/contacts
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: '100'
        properties: 'email,firstname,lastname,phone,lifecyclestage,associatedcompanyid'
        associations: companies
      data_path: .results
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .properties.email
          blueprint: '"ocean_hubspotContact"'
          properties:
            email: .properties.email
            firstname: .properties.firstname
            lastname: .properties.lastname
            phone: .properties.phone
            lifecyclestage: .properties.lifecyclestage
            createdAt: .createdAt
            updatedAt: .updatedAt
          relations:
            company: (.properties.associatedcompanyid | if . == "" then null else . end)
  - kind: /crm/v3/objects/companies
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: '100'
        properties: 'name,domain,industry,city,state,country,numberofemployees,annualrevenue'
      data_path: .results
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .properties.name
          blueprint: '"ocean_hubspotCompany"'
          properties:
            name: .properties.name
            domain: .properties.domain
            industry: .properties.industry
            city: .properties.city
            state: .properties.state
            country: .properties.country
            numberOfEmployees: .properties.numberofemployees
            annualRevenue: .properties.annualrevenue
            createdAt: .createdAt
            updatedAt: .updatedAt
  - kind: /crm/v3/objects/deals
    selector:
      query: 'true'
      method: GET
      query_params:
        limit: '100'
        properties: 'dealname,amount,dealstage,pipeline,closedate,hs_deal_stage_probability,dealtype'
        associations: companies,contacts
      data_path: .results
    port:
      entity:
        mappings:
          identifier: .id | tostring
          title: .properties.dealname
          blueprint: '"ocean_hubspotDeal"'
          properties:
            dealname: .properties.dealname
            amount: .properties.amount
            dealstage: .properties.dealstage
            pipeline: .properties.pipeline
            closedate: .properties.closedate
            probability: .properties.hs_deal_stage_probability
            dealtype: .properties.dealtype
            createdAt: .createdAt
            updatedAt: .updatedAt
          relations:
            companies: ((.associations.companies.results // []) | map(.id | tostring))
            contacts: ((.associations.contacts.results // []) | map(.id | tostring))
```

**How the mapping translates to HTTP requests:**

Based on the first resource mapping (`/crm/v3/objects/contacts`), Port will make this HTTP request:

```http
GET https://api.hubapi.com/crm/v3/objects/contacts?limit=100&properties=email,firstname,lastname,phone,lifecyclestage,associatedcompanyid&associations=companies
Authorization: Bearer pat-your-token-here
```

The HubSpot API will respond with:
```json
{
  "results": [
    {
      "id": "123456",
      "properties": {
        "email": "john@example.com",
        "firstname": "John",
        "lastname": "Doe",
        "phone": "+1234567890",
        "lifecyclestage": "customer",
        "associatedcompanyid": "789"
      },
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-02T00:00:00.000Z"
    }
  ],
  "paging": {
    "next": {
      "after": "eyJpZCI6MTIzNDU2fQ=="
    }
  }
}
```

Port then:
1. Uses `data_path: .results` to extract the array of contacts
2. Applies the JQ mappings to create Port entities (e.g., `identifier: .id | tostring`, `title: .properties.email`)
3. Uses pagination config to fetch more pages if `paging.next.after` exists

**Understanding Ocean Custom-specific fields:**
- `kind`: **This is the API endpoint path itself** (e.g., `/crm/v3/objects/contacts`). Each endpoint is tracked separately in Port's UI.
- `data_path`: **JQ expression to extract the data array** from the API response. 
  
  **Why do we need this?** HubSpot API responses wrap data in objects. For example:
  ```json
  {
    "results": [...],
    "paging": {...}
  }
  ```
  We use `data_path: .results` to extract just the array of contacts.
  
- `query_params`: Query parameters to send with the request (e.g., `limit: "100"`, `properties: "email,firstname,..."`).

**Additional Ocean Custom configurations:**

For advanced configurations like Basic Auth, API Key Auth, Offset/Page Pagination, Dynamic Path Parameters, and Custom Headers, see the [Ocean Custom Integration documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview).

**Save and Sync:**

1. Click **"Save"**
2. The integration will automatically start syncing
3. Go to **"Software Catalog"** → **"Entities"** to see your data

✅ **Checkpoint**: After 1-2 minutes, you should see entities appearing in Port!

---

## 6. Verify the Integration

Go to Port's catalog and check if data is synced in. You should see HubSpot contacts, companies, and deals appearing as entities.

---

## 7. Bonus Task: Add a New Kind

**Challenge**: Add another endpoint to sync additional data!

**Find an API Endpoint:**

Browse the [HubSpot API documentation](https://developers.hubspot.com/docs/api/overview) and find another endpoint you'd like to sync.

**Example endpoints to consider:**
- `/crm/v3/objects/products` - Get products from your catalog
- `/crm/v3/objects/line_items` - Get line items from deals
- `/crm/v3/objects/tickets` - Get support tickets

**Create a Blueprint (if needed):**

If the new endpoint represents a different entity type:
1. Create a new blueprint following step 4.2
2. Note the blueprint identifier

**Add the Resource Mapping:**

1. Go back to your integration configuration (Port UI → Data Sources → hubspot-integration)
2. Add a new resource block following the pattern from step 5
3. Update the `kind`, `data_path`, `query_params`, and `mappings` accordingly

**Test It:**

1. Save the configuration
2. Wait for sync (1-2 minutes)
3. Verify entities appear in Port

**💡 Hint**: HubSpot uses cursor pagination with `after` query parameter. The cursor is found in `paging.next.after` in the response. HubSpot also requires you to specify which `properties` you want in the query params.

---

## Troubleshooting

### Issue: Pod not starting

```bash
# Check pod status
kubectl describe pod -l app.kubernetes.io/instance=hubspot-integration -n workshop-test

# Common issues:
# - Wrong credentials → Check Port client ID/secret
# - Wrong API token → Verify HubSpot API token is correct (should start with pat-)
```

### Issue: No entities syncing

1. Check integration status in Port UI → Data Sources → hubspot-integration
2. Verify blueprints are created correctly
3. Verify the `blueprint` field in your mapping
4. Check `data_path` - HubSpot API wraps responses, so you need `data_path: .results` for all endpoints
5. Verify `query_params` includes the `properties` you're trying to map

### Issue: Authentication errors

- Verify HubSpot API token is correct (starts with `pat-`)
- Check that your HubSpot Private App has the required scopes: `crm.objects.contacts.read`, `crm.objects.companies.read`, `crm.objects.deals.read`
- Ensure the Private App is active in your HubSpot account

### Issue: Missing properties

- HubSpot requires you to specify which properties you want in the `properties` query parameter
- Check that all properties you're mapping are included in the `query_params.properties` field
- Some properties may require specific scopes in your HubSpot Private App

---

## Next Steps

Congratulations! 🎉 You've successfully integrated HubSpot with Port.

**What you learned:**
- ✅ How to configure cursor pagination with HubSpot's API
- ✅ How to map HubSpot CRM data using `data_path` and `query_params`
- ✅ How to use JQ expressions for data transformation and relations
- ✅ How to handle HubSpot's property-based query system

**Try these next:**
- Integrate another tool using Ocean Custom (try Slack or Zendesk exercises)
- Experiment with different query parameters and property selection
- Try mapping associations and relations between entities
- Add more HubSpot endpoints (products, tickets, etc.)

---

## Resources

- [Ocean Custom Integration Documentation](https://docs.port.io/build-your-software-catalog/custom-integration/ocean-custom-integration/overview)
- [HubSpot API Documentation](https://developers.hubspot.com/docs/api/overview)
- [HubSpot CRM Objects API](https://developers.hubspot.com/docs/api/crm/understanding-the-crm)
- [JQ Expression Guide](https://stedolan.github.io/jq/manual/)

