# Ocean Custom Integration Workshop

Hands-on workshop materials for Port SEs and TSMs to learn how to integrate any tool using Ocean Custom Integration.

## 🎯 Workshop Goals

By the end of this workshop, each SE will be able to integrate with any tool during a POC using Ocean Custom Integration.

## 📚 Workshop Structure

This workshop consists of **hands-on exercises** where you'll build real integrations step-by-step.

### Each Exercise Includes:

1. **Use Case** - What problem does this integration solve?
2. **Tool Overview** - Which tool will you integrate?
3. **Prerequisites** - Port credentials and K8s cluster access
4. **Installation** - Helm install commands (copy-paste ready)
5. **Blueprints** - JSON blocks to create in Port
6. **Resource Mapping** - How to map API data to Port entities
7. **Bonus Task** - Add a new endpoint to the mapping

## 🏋️ Available Exercises

Each exercise is a complete, self-contained integration lab:

- ✅ **Exercise 1: Slack** - Bearer token, cursor pagination
- ✅ **Exercise 2: Zendesk** - Basic auth, cursor pagination
- ✅ **Exercise 3: HubSpot** - Bearer token, cursor pagination
- ✅ **Exercise 4: Cursor** - Basic auth, POST requests
- ✅ **Exercise 5: Claude AI** - Bearer token, custom headers
- 🚧 **Exercise 6: Incident.io** - Coming soon
- 🚧 **Exercise 7: Notion** - Coming soon
- 🚧 **Exercise 8: Rootly** - Coming soon

## 🚀 Getting Started

1. **Choose an exercise** from the `exercises/` folder
2. **Open the README.md** in that exercise folder
3. **Follow step-by-step** - all commands are copy-paste ready
4. **Ask questions** in the workshop Slack channel if you get stuck

## 📋 Workshop Details

- **Duration**: 1 hour
- **Format**: Virtual, parallel execution (each SE works independently)
- **Prerequisites**: 
  - Comfortable with YAML and kubectl
  - MacOS (all commands are Mac-specific)
  - AWS SSO access (credentials provided)

## 📁 Repository Structure

```
├── exercises/          # Hands-on integration exercises
│   ├── slack/         # Exercise 1: Slack integration
│   ├── zendesk/       # Exercise 2: Zendesk integration
│   └── ...
├── templates/         # Templates for creating new exercises
├── docs/              # Reference materials and notes
└── README.md          # This file
```

## 💡 Tips

- All commands are **copy-paste ready** - no manual editing needed
- Each exercise is **independent** - start with any one
- **Checkpoints** are marked throughout - verify your progress
- If stuck, check the **Troubleshooting** section in each exercise

## 🆘 Support

For questions or issues during the workshop, reach out to the workshop facilitators.

