# {{PROJECT_NAME}} Azure Pipeline Setup

{{PROJECT_NAME}} uses GitHub Actions with Azure OIDC. Do not store Azure client secrets in GitHub.

## GitHub Environments

Create these GitHub environments only when later workflows need deployment approvals or environment-scoped configuration:

- `dev`
- `staging`
- `production`

Set deployment approvals for `staging` and `production` before enabling those deployments. The default Voxa-style `dev` infrastructure deployment uses repository secrets.

## Repository Secrets

Configure these as GitHub repository secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_LOCATION`
- `AZURE_RESOURCE_GROUP`
- `OPENAI_API_KEY`

Do not store Azure client secrets; the workflow uses OIDC against a user-assigned managed identity.

Required only if enabling repository ruleset automation:

- `REPO_ADMIN_TOKEN` with repository administration/ruleset permissions.

Required later for TestFlight:

- `{{ENV_PREFIX}}_APP_IDENTIFIER`
- `{{ENV_PREFIX}}_APPLE_ID`
- `{{ENV_PREFIX}}_ITC_TEAM_ID`
- `{{ENV_PREFIX}}_TEAM_ID`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_KEYCHAIN_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `{{ENV_PREFIX}}_XCODE_PROJECT` or `{{ENV_PREFIX}}_XCODE_WORKSPACE`
- `{{ENV_PREFIX}}_XCODE_SCHEME`

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
- a federated credential scoped to `{{GITHUB_REF}}` using GitHub's immutable owner/repository subject format when IDs are available;
- the target {{PROJECT_NAME}} resource group;
- contributor access to the target {{PROJECT_NAME}} resource group.

Copy these deployment outputs into repository secrets:

- `azureClientId` -> `AZURE_CLIENT_ID`
- `azureTenantId` -> `AZURE_TENANT_ID`
- `azureSubscriptionId` -> `AZURE_SUBSCRIPTION_ID`
- `azureLocation` -> `AZURE_LOCATION`
- `azureResourceGroup` -> `AZURE_RESOURCE_GROUP`

Pull request infrastructure validation does not log in to Azure. It only runs local guard tests and Bicep lint so initial setup PRs can pass before the Azure OIDC repository secrets exist.

Repeat for `staging` and `production` when those environments are introduced.

The application Function App uses its own managed identity from Bicep. Do not reuse the pipeline identity as the app runtime identity.
