#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-{{GITHUB_OWNER}}/{{REPO_NAME}}}"
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

az account set --subscription "$SUBSCRIPTION_ID"

az deployment sub create \
  --name "{{REPO_NAME}}-bootstrap-${ENVIRONMENT}" \
  --location "$LOCATION" \
  --template-file "$BOOTSTRAP_BICEP_FILE" \
  --parameters \
    environmentName="$ENVIRONMENT" \
    location="$LOCATION" \
    githubOrg="$GITHUB_ORG" \
    githubRepo="$GITHUB_REPO" \
    githubEnvironment="$ENVIRONMENT" \
    pipelineResourceGroupName="$PIPELINE_RG" \
    targetResourceGroupName="$TARGET_RG" \
    pipelineIdentityName="$IDENTITY_NAME" \
  --query properties.outputs

echo
echo "Copy these output values into the '${ENVIRONMENT}' GitHub environment variables:"
echo "AZURE_CLIENT_ID      = azureClientId.value"
echo "AZURE_TENANT_ID      = azureTenantId.value"
echo "AZURE_SUBSCRIPTION_ID= azureSubscriptionId.value"
echo "AZURE_LOCATION       = azureLocation.value"
echo "AZURE_RESOURCE_GROUP = azureResourceGroup.value"
