# Implementation Plan

## Phase 1: Inventory

- Compare Deja Groove, Kairos, and Voxa shared files.
- Classify files as template-owned, module-owned, or project-owned.
- Identify substitutions needed per project.

## Phase 2: Template Files

- Copy the stable common files into `template/`.
- Replace hard-coded project names with template variables.
- Split optional modules into separate overlays.

Expected overlays:

- `base`
- `azure-managed-identity-oidc`
- `azure-app-registration-oidc`
- `ios-testflight`
- `backend-function`

## Phase 3: Bootstrap Scripts

Create scripts for:

- new project generation
- applying the template to an existing repository
- drift detection
- GitHub Project board creation
- GitHub ruleset setup
- Azure OIDC bootstrap

## Phase 4: Verification

Each generated/applied repo should pass:

- local hook setup
- changeset script tests
- release script tests
- workflow syntax checks
- infrastructure guard tests where applicable
- dry-run drift detection

## Phase 5: Maintenance

- Version the template.
- Record template state in each target repo.
- Add a changelog for template changes.
- Provide an update command that makes reviewable pull requests against target repos.

