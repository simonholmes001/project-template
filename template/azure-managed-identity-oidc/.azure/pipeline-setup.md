# {{PROJECT_NAME}} Azure Pipeline Setup

{{PROJECT_NAME}} uses GitHub Actions with Azure OIDC. Do not store Azure client secrets in GitHub.

## GitHub Environments

Create these GitHub environments when needed:

- `dev`
- `staging`
- `production`

Set deployment approvals for `staging` and `production` before enabling those deployments.

## GitHub Environment Variables

For each environment, configure:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_LOCATION`
- `AZURE_RESOURCE_GROUP`

Configure `OPENAI_API_KEY` as an environment secret for environments that deploy the backend. Do not store Azure client secrets; the workflow uses OIDC against a user-assigned managed identity.

## Repository Secrets

Required now:

- `OPENAI_API_KEY` for Codex PR review and backend deployment. Prefer an environment-scoped value for deployment environments.

Required only if enabling repository ruleset automation:

- `REPO_ADMIN_TOKEN` with repository administration/ruleset permissions.

Required later for TestFlight:

- `{{PROJECT_NAME_UPPER}}_APP_IDENTIFIER`
- `{{PROJECT_NAME_UPPER}}_APPLE_ID`
- `{{PROJECT_NAME_UPPER}}_ITC_TEAM_ID`
- `{{PROJECT_NAME_UPPER}}_TEAM_ID`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_KEYCHAIN_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `{{PROJECT_NAME_UPPER}}_XCODE_PROJECT` or `{{PROJECT_NAME_UPPER}}_XCODE_WORKSPACE`
- `{{PROJECT_NAME_UPPER}}_XCODE_SCHEME`

## Azure OIDC Bootstrap

Run this once from an Azure CLI session with permission to create resource groups, managed identities, federated credentials, and role assignments:

```bash
az login
az account set --subscription "<subscription-id>"

AZURE_SUBSCRIPTION_ID="<subscription-id>" \
./scripts/setup-azure-auth-for-pipeline.sh dev
```

The script deploys `infrastructure/bootstrap/main.bicep`, which creates:

- a separate pipeline identity resource group;
- a user-assigned managed identity for GitHub Actions;
- an environment-scoped federated credential;
- the target {{PROJECT_NAME}} resource group;
- contributor access to the target {{PROJECT_NAME}} resource group.

Copy these deployment outputs into the `dev` GitHub environment variables:

- `azureClientId` -> `AZURE_CLIENT_ID`
- `azureTenantId` -> `AZURE_TENANT_ID`
- `azureSubscriptionId` -> `AZURE_SUBSCRIPTION_ID`
- `azureLocation` -> `AZURE_LOCATION`
- `azureResourceGroup` -> `AZURE_RESOURCE_GROUP`

Pull request infrastructure validation does not log in to Azure. It only runs local guard tests and Bicep lint so initial setup PRs can pass before the Azure OIDC environment variables exist.

Repeat for `staging` and `production` when those environments are introduced.

The application Function App uses its own managed identity from Bicep. Do not reuse the pipeline identity as the app runtime identity.
