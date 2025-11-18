# Workshop Cleanup Scripts

## cleanup-workshop.sh

A comprehensive cleanup script that removes all workshop resources from Kubernetes and Port.

### What it does:

1. **Deletes Kubernetes integrations** - Uninstalls all Helm releases for workshop integrations
2. **Deletes Port integrations** - Removes all integrations from Port via API
3. **Deletes Port blueprints** - Removes all blueprints (with all entities) from Port via API

### Prerequisites:

- `kubectl` configured and connected to the workshop cluster
- `helm` installed
- `curl` and `jq` installed
- Port credentials configured (via environment variables or defaults in script)

### Usage:

```bash
# Make sure you're connected to the K8s cluster
kubectl get nodes

# Run the cleanup script
./scripts/cleanup-workshop.sh
```

### Configuration:

The script uses these defaults (can be overridden via environment variables):

- **Namespace**: `workshop-test`
- **Port API URL**: `https://api.getport.io`
- **Port Client ID**: From `SECRETS.md` (or set `PORT_CLIENT_ID` env var)
- **Port Client Secret**: From `SECRETS.md` (or set `PORT_CLIENT_SECRET` env var)

### Custom Port Credentials:

```bash
export PORT_CLIENT_ID="your-client-id"
export PORT_CLIENT_SECRET="your-client-secret"
./scripts/cleanup-workshop.sh
```

### What gets deleted:

**Kubernetes Integrations:**
- `slack-integration`
- `zendesk-integration`
- `hubspot-integration`
- `cursor-integration`
- `claude-integration`

**Port Blueprints:**
- Slack: `ocean_slackUser`, `ocean_slackChannel`
- Zendesk: `zendesk_organization`, `zendesk_user`, `zendesk_ticket`, `zendesk_comment`
- HubSpot: `ocean_hubspotContact`, `ocean_hubspotCompany`, `ocean_hubspotDeal`, `ocean_hubspotFeatureRequest`
- Cursor: `cursor_usage_record`
- Claude AI: `claude_usage_record`

### Safety:

- The script asks for confirmation before proceeding
- It handles missing resources gracefully (warns but continues)
- It provides colored output for easy status tracking

### Notes:

- Blueprint deletion includes all entities (uses `delete_blueprint=true`)
- Integration deletion happens after blueprint deletion
- The script will continue even if some resources are missing (404 errors)

