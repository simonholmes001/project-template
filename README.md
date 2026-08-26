# Project Template

[![CI](https://github.com/simonholmes001/project-template/actions/workflows/ci.yaml/badge.svg)](https://github.com/simonholmes001/project-template/actions/workflows/ci.yaml)
![Template](https://img.shields.io/badge/template-generator-blue)
![Azure OIDC](https://img.shields.io/badge/Azure%20OIDC-managed%20identity-0078D4)
![GitHub Projects](https://img.shields.io/badge/GitHub%20Projects-v2-24292f)
![Node](https://img.shields.io/badge/node-%3E%3D22-339933)

Reusable project bootstrap for repositories that should follow the same operating model as Deja Groove, Kairos, and Voxa.

## Purpose

This project will become the source template for new application repositories. It should remove the need to manually restate the same setup for every new project:

- GitHub Actions workflows
- local git hooks
- pull request checks
- Codex PR review automation
- review rubrics
- changeset and release process
- GitHub ruleset/branch protection automation
- GitHub Project board structure
- Azure infrastructure validation/deployment conventions
- Azure OIDC bootstrap conventions

The template should separate stable shared mechanics from project-specific choices.

## Recommended Shape

Use a generator-style template rather than a plain copy-only repository.

The template should contain:

- `template/` for files copied into a target repo
- `scripts/` for bootstrap/apply/update commands
- `docs/` for design decisions and operating instructions
- a project manifest, eventually, for per-project answers such as app name, repo name, runtime, Azure profile, and enabled modules

## Template Modes

The default mode should support a simple Azure-backed application:

- GitHub Actions
- GitHub OIDC
- user-assigned managed identity for deployment
- Azure RBAC scoped to the target environment/resource group
- no long-lived Azure client secrets

Alternate modes should be explicit:

- `azure-app-registration-oidc` for apps that need Entra app/API permissions, Graph permissions, multi-tenant behavior, or organization-standard service principals
- `ios-testflight` for apps that need App Store/TestFlight release workflows
- `backend-function` for Azure Function deployment
- `repo-only` for projects that only need repo hygiene, PR checks, release, hooks, and Project board setup

## How To Create A New Repo

Use `scripts/new-project.sh` when you want to start a new local repository that already has the standard CI, hooks, release, PR review, ruleset, Project board conventions, and optional Azure/iOS overlays.

There are two separate things to create:

1. the GitHub Project board, which gives you the same project-management structure as Deja Groove and Kairos;
2. the Git repository, which gives you the source-code repo with the shared CI/CD and automation files.

Create the Project board first if you want the generated repo to know its Project number immediately.

```bash
cd ~/Projects/Applications/Project_Template

./scripts/create-github-project.sh \
  --title "voxa" \
  --owner "simonholmes001"
```

The command prints:

```text
PROJECT_OWNER=simonholmes001
PROJECT_NUMBER=<number>
```

Use that number in the next command.

Example: create a new Azure + iOS project called `Voxa`:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/new-project.sh \
  --name "Voxa" \
  --repo "voxa" \
  --github-owner "simonholmes001" \
  --project-number "<github-project-number>" \
  --destination "../Voxa" \
  --profile azure-managed-identity-oidc \
  --module ios-testflight \
  --module backend-function
```

That creates `~/Projects/Applications/Voxa`, runs `git init`, copies the rendered template files, and writes `.project-template.yml` so the repo records which template profile/modules it uses.

The generated folder is now a normal local git repo. Inspect and test it:


```bash
cd ~/Projects/Applications/Voxa
scripts/setup-hooks.sh
npm test
git status
```

When the local repo looks right, commit it and create the GitHub repo:

```bash
git add .
git commit -m "chore: bootstrap project foundation"
gh repo create simonholmes001/voxa --private --source . --remote origin
git push -u origin main
```

If you want `new-project.sh` to create the GitHub repo too, add `--create-github`:

```bash
./scripts/new-project.sh \
  --name "Voxa" \
  --repo "voxa" \
  --github-owner "simonholmes001" \
  --destination "../Voxa" \
  --profile azure-managed-identity-oidc \
  --module ios-testflight \
  --module backend-function \
  --create-github
```

This one command creates the local repo and the GitHub repo, but you should still run `scripts/setup-hooks.sh`, `npm test`, commit, and push from inside the generated project.

## How To Apply It To An Existing Repo

Use `scripts/apply-template.sh` when a repo already exists and you want to add the standard structure:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/apply-template.sh \
  --target "../Kairos" \
  --profile azure-app-registration-oidc
```

By default, this refuses to overwrite files that already exist and differ. Use `--force` only from a branch where the resulting diff can be reviewed.

## How To Check Drift

Use `scripts/drift-check.sh` to see whether a repo still matches the rendered template:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/drift-check.sh \
  --target "../Kairos" \
  --name "Kairos" \
  --repo "kairos" \
  --profile azure-app-registration-oidc
```

It prints `missing:` or `different:` entries and does not write anything.

## How To Update Existing Repos

Use `scripts/update-project.sh` from a feature branch in the target repo. It wraps `apply-template.sh --force`.

```bash
cd ~/Projects/Applications/Project_Template

./scripts/update-project.sh \
  --target "../Deja_Groove" \
  --name "Deja Groove" \
  --repo "deja-groove" \
  --profile azure-app-registration-oidc \
  --module ios-testflight \
  --module backend-function
```

## How To Create The GitHub Project Board

After creating the GitHub repo, create the matching Project v2 board:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/create-github-project.sh \
  --title "voxa" \
  --owner "simonholmes001"
```

This creates the board if it does not exist and ensures the standard `Status` and `Priority` fields are present. GitHub creates default metadata fields such as title, assignees, labels, and repository automatically.

The command prints:

```text
PROJECT_OWNER=simonholmes001
PROJECT_NUMBER=<number>
```

Use that number with `--project-number` when generating the repo, or set it later as the `PROJECT_NUMBER` repository variable.

## Azure Bootstrap After Repo Creation

For the default new-project profile, bootstrap Azure OIDC after the GitHub repo exists:

```bash
cd ~/Projects/Applications/Voxa

az login
az account set --subscription "<subscription-id>"

AZURE_SUBSCRIPTION_ID="<subscription-id>" \
./scripts/setup-azure-auth-for-pipeline.sh dev
```

Copy the script outputs into the `dev` GitHub environment variables:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_LOCATION`
- `AZURE_RESOURCE_GROUP`

## Current Status

Usable local template implementation.

Implemented:

- base overlay
- Azure managed identity OIDC overlay
- Azure App Registration OIDC documentation overlay
- iOS/TestFlight overlay
- backend-function marker overlay
- new project generation
- existing repo apply/update
- drift detection
- GitHub Project board creation helper
