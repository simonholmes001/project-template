# Azure Pipeline Setup

This profile uses the classic GitHub Actions Azure OIDC pattern:

```text
GitHub Actions -> OIDC -> Entra App Registration / service principal -> Azure RBAC
```

Configure these GitHub environment variables or secrets according to the workflow files in this repository:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_LOCATION`
- `AZURE_RESOURCE_GROUP`

Do not configure a long-lived Azure client secret. The Entra app registration should use a federated credential for GitHub Actions.

Use this profile when the app needs Entra application/API permissions, Microsoft Graph permissions, multi-tenant behavior, or an organization-standard service principal.

For new Azure-only apps that only need Azure RBAC, prefer the `azure-managed-identity-oidc` profile.

