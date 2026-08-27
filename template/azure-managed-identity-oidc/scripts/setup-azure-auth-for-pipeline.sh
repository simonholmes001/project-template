#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-{{GITHUB_OWNER}}/{{REPO_NAME}}}"
GITHUB_REF="${GITHUB_REF:-{{GITHUB_REF}}}"
GITHUB_OWNER_ID="${GITHUB_OWNER_ID:-{{GITHUB_OWNER_ID}}}"
GITHUB_REPO_ID="${GITHUB_REPO_ID:-{{GITHUB_REPO_ID}}}"
LOCATION="${AZURE_LOCATION:-{{AZURE_LOCATION}}}"
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-}"
PIPELINE_RG="${AZURE_PIPELINE_RESOURCE_GROUP:-rg-{{REPO_NAME}}-pipeline-identity}"
TARGET_RG="${AZURE_RESOURCE_GROUP:-rg-{{REPO_NAME}}-${ENVIRONMENT}}"
IDENTITY_NAME="${AZURE_PIPELINE_IDENTITY_NAME:-id-{{REPO_NAME}}-github-actions}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOOTSTRAP_BICEP_FILE="$ROOT_DIR/infrastructure/bootstrap/main.bicep"

if [ -z "$SUBSCRIPTION_ID" ]; then
  echo "AZURE_SUBSCRIPTION_ID is required." >&2
  exit 1
fi

GITHUB_ORG="${GITHUB_REPOSITORY%%/*}"
GITHUB_REPO="${GITHUB_REPOSITORY#*/}"

if [ -z "$GITHUB_OWNER_ID" ] || [ -z "$GITHUB_REPO_ID" ]; then
  if command -v gh >/dev/null 2>&1 && gh auth status -h github.com >/dev/null 2>&1; then
    REPOSITORY_JSON="$(gh api "repos/${GITHUB_REPOSITORY}")"
    GITHUB_OWNER_ID="${GITHUB_OWNER_ID:-$(echo "$REPOSITORY_JSON" | jq -r '.owner.id // empty')}"
    GITHUB_REPO_ID="${GITHUB_REPO_ID:-$(echo "$REPOSITORY_JSON" | jq -r '.id // empty')}"
  else
    echo "Warning: gh is not authenticated; using name-based GitHub OIDC subject fallback." >&2
    echo "For immutable subject claims, set GITHUB_OWNER_ID and GITHUB_REPO_ID." >&2
  fi
fi

az account set --subscription "$SUBSCRIPTION_ID"

az deployment sub create \
  --name "{{REPO_NAME}}-bootstrap-${ENVIRONMENT}" \
  --location "$LOCATION" \
  --template-file "$BOOTSTRAP_BICEP_FILE" \
  --parameters \
    environmentName="$ENVIRONMENT" \
    location="$LOCATION" \
    githubOrg="$GITHUB_ORG" \
    githubOrgId="$GITHUB_OWNER_ID" \
    githubRepo="$GITHUB_REPO" \
    githubRepoId="$GITHUB_REPO_ID" \
    githubRef="$GITHUB_REF" \
    pipelineResourceGroupName="$PIPELINE_RG" \
    targetResourceGroupName="$TARGET_RG" \
    pipelineIdentityName="$IDENTITY_NAME" \
  --query properties.outputs

echo
echo "Copy these output values into repository secrets:"
echo "AZURE_CLIENT_ID      = azureClientId.value"
echo "AZURE_TENANT_ID      = azureTenantId.value"
echo "AZURE_SUBSCRIPTION_ID= azureSubscriptionId.value"
echo "AZURE_LOCATION       = azureLocation.value"
echo "AZURE_RESOURCE_GROUP = azureResourceGroup.value"
