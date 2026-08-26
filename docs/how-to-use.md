# How To Use This Template

## Mental Model

This template is a project factory.

Instead of telling Codex every time:

> Please add the same GitHub Actions, hooks, CI, PR review, changesets, release process, Azure OIDC setup, and GitHub Project board structure as Deja Groove and Kairos.

you run one command from `Project_Template`.

The command creates a new folder for your new app and copies the standard structure into it.

## The Most Common Command

For a new Azure-backed iOS app:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/new-project.sh \
  --name "My New App" \
  --repo "my-new-app" \
  --github-owner "simonholmes001" \
  --project-number "<github-project-number>" \
  --destination "../My_New_App" \
  --profile azure-managed-identity-oidc \
  --module ios-testflight \
  --module backend-function \
  --description "My New App foundation"
```

What each argument means:

- `--name`: human-readable app name.
- `--repo`: GitHub repository slug.
- `--github-owner`: GitHub user or organization.
- `--project-number`: GitHub Project v2 number used by the auto-sort workflow. You can omit this and set the `PROJECT_NUMBER` repository variable later.
- `--destination`: local folder to create.
- `--profile`: main infrastructure/authentication style.
- `--module`: optional extra template pack. Repeat it for multiple modules.
- `--description`: package description written into `package.json`.

## What You Get

The new folder will contain:

- `.github/workflows/*`
- `.github/scripts/*`
- `.github/review-rubrics/*`
- `.githooks/pre-commit`
- `scripts/setup-hooks.sh`
- `.changeset/*`
- `.project-template.yml`
- optional Azure infrastructure/bootstrap files
- optional iOS/TestFlight files

## After Running It

Go into the generated project:

```bash
cd ~/Projects/Applications/My_New_App
```

Install the local git hooks:

```bash
scripts/setup-hooks.sh
```

Run the template test suite:

```bash
npm test
```

Check the generated files:

```bash
git status
```

Commit:

```bash
git add .
git commit -m "chore: bootstrap project foundation"
```

Create/push the GitHub repo:

```bash
gh repo create simonholmes001/my-new-app --private --source . --remote origin
git push -u origin main
```

## GitHub Project Board

Create the matching board:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/create-github-project.sh \
  --title "my-new-app" \
  --owner "simonholmes001"
```

The command prints the `PROJECT_OWNER` and `PROJECT_NUMBER` values to use in the generated repo.

## Azure

For the default `azure-managed-identity-oidc` profile, Azure is bootstrapped from inside the generated repo:

```bash
cd ~/Projects/Applications/My_New_App

az login
az account set --subscription "<subscription-id>"

AZURE_SUBSCRIPTION_ID="<subscription-id>" \
./scripts/setup-azure-auth-for-pipeline.sh dev
```

Then copy the printed outputs into the `dev` GitHub environment variables.

## Existing Repos

To check whether an existing repo has drifted from the template:

```bash
cd ~/Projects/Applications/Project_Template

./scripts/drift-check.sh \
  --target "../Kairos" \
  --name "Kairos" \
  --repo "kairos" \
  --profile azure-app-registration-oidc
```

To apply/update the template from a feature branch:

```bash
./scripts/update-project.sh \
  --target "../Kairos" \
  --name "Kairos" \
  --repo "kairos" \
  --profile azure-app-registration-oidc
```
