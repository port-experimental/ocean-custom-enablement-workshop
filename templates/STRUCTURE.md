# Workshop Materials Structure

## Folder Organization

```
ocean-custom-workshop-materials/
├── README.md                          # Main workshop overview
├── templates/
│   ├── INTEGRATION_TEMPLATE.md        # Master template for all integrations
│   ├── STRUCTURE.md                   # This file
│   └── QUICK_REFERENCE.md             # Quick reference guide
└── integrations/
    ├── slack/
    │   ├── README.md                  # Step-by-step guide
    │   ├── blueprints.json            # All blueprints in one file
    │   └── port-app-config.yml        # Example mapping (optional)
    ├── zendesk/
    │   ├── README.md
    │   ├── blueprints.json
    │   └── port-app-config.yml
    ├── incident-io/
    │   ├── README.md
    │   ├── blueprints.json
    │   └── port-app-config.yml
    ├── notion/
    │   ├── README.md
    │   ├── blueprints.json
    │   └── port-app-config.yml
    └── rootly/
        ├── README.md
        ├── blueprints.json
        └── port-app-config.yml
```

## File Naming Conventions

- **README.md**: Main workshop guide (follows INTEGRATION_TEMPLATE.md)
- **blueprints.json**: JSON array of all blueprints (one per integration)
- **port-app-config.yml**: Example resource mapping (for reference, not copy-paste)

## Blueprint JSON Format

Each `blueprints.json` should contain an array of blueprint objects:

```json
[
  {
    "identifier": "blueprint_1",
    "title": "Blueprint 1",
    "icon": "IconName",
    "schema": {
      "properties": { ... }
    }
  },
  {
    "identifier": "blueprint_2",
    "title": "Blueprint 2",
    "icon": "IconName",
    "schema": {
      "properties": { ... },
      "relations": { ... }
    }
  }
]
```

## Integration README Sections

Each integration README should follow this exact structure:

1. **Use Case** (2-3 sentences + examples)
2. **Tool Overview** (tool name, API docs, auth method, base URL, data synced)
3. **Prerequisites & Environment Setup** (Port access, K8s connection, API credentials)
4. **Create Blueprints in Port** (JSON blocks for each blueprint)
5. **Install the Integration** (Helm install command with placeholders)
6. **Add Resource Mapping** (YAML template with explanations)
7. **Verify the Integration** (check entities, check logs)
8. **Bonus Task** (add new kind)
9. **Troubleshooting** (common issues)
10. **Next Steps** (what they learned, what to try next)
11. **Resources** (links to docs)

## Copy-Paste Ready Requirements

All commands and code blocks must be:
- ✅ Copy-paste ready (no manual editing needed except for placeholders)
- ✅ Clearly marked placeholders: `[PLACEHOLDER]`
- ✅ Include verification checkpoints: ✅ **Checkpoint**
- ✅ Include time estimates where helpful
- ✅ Include visual indicators: 💡 **Tip**, ⚠️ **Warning**

## Placeholder Conventions

Use these placeholder formats:
- `[YOUR_PORT_CLIENT_ID]` - User needs to replace
- `[YOUR_API_TOKEN]` - User needs to replace
- `[integration-name]` - User chooses (e.g., `slack`, `zendesk`)
- `[blueprint_identifier]` - Matches blueprint JSON identifier
- `[Tool Name]` - Actual tool name
- `[API docs link]` - Link to tool's API documentation

## Checklist for Each Integration

Before marking an integration as ready:

- [ ] README.md follows template structure
- [ ] All placeholders are clearly marked
- [ ] Blueprints JSON is valid and tested
- [ ] Helm install command is correct
- [ ] Resource mapping YAML is correct
- [ ] All links work
- [ ] Copy-paste commands tested
- [ ] Checkpoints are clear
- [ ] Troubleshooting covers common issues
- [ ] Integration tested end-to-end

