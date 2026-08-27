# Azure Identity Decision

## Decision

For new simple Azure-only applications, prefer:

```text
GitHub Actions -> OIDC -> user-assigned managed identity -> Azure RBAC
```

Keep this alternate profile available:

```text
GitHub Actions -> OIDC -> Entra App Registration / service principal -> Azure RBAC
```

Do not use long-lived Azure client secrets unless there is no viable alternative.

## Rationale

Both OIDC patterns can be valid.

The App Registration pattern is the classic GitHub Actions Azure OIDC setup. It is acceptable when it uses federated credentials and no client secret.

The user-assigned managed identity pattern is a better default for new Azure-only apps because the deployment identity is an Azure resource. That makes it easier to express in Bicep/ARM and keep bootstrap closer to infrastructure-as-code.

The template uses Voxa's current managed-identity variant:

- repository secrets for Azure pipeline configuration;
- default Azure region `swedencentral`;
- a federated credential scoped to `refs/heads/main`;
- immutable GitHub owner/repository numeric IDs when available.

## Decision Rule

Use user-assigned managed identity plus OIDC when:

- the app deploys only to Azure
- the pipeline identity only needs Azure RBAC
- the team wants Azure resources managed through code
- minimal portal/manual setup is preferred

Use App Registration plus OIDC when:

- the app needs Entra application/API permissions
- the app needs Microsoft Graph permissions
- the app is multi-tenant
- the organization mandates standard service principals
- the identity must live primarily in Microsoft Entra ID rather than as an Azure resource

## Implication For Existing Repos

Kairos is not wrong if it uses App Registration plus federated credentials and no client secret.

Voxa's managed identity approach should become the default for new Azure-only projects.
