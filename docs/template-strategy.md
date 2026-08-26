# Template Strategy

## Observed Common Structure

Deja Groove and Kairos already share the same operating structure:

- `.githooks/pre-commit`
- `scripts/setup-hooks.sh`
- `.github/CODEOWNERS`
- `.github/review-rubrics/*`
- `.github/scripts/changeset-check.*`
- `.github/scripts/compute-next-release.*`
- `.github/scripts/codex-pr-review*`
- `.github/scripts/ensure-codex-ruleset.mjs`
- `.github/workflows/ci.yaml`
- `.github/workflows/pr-checks.yaml`
- `.github/workflows/codex-pr-review.yaml`
- `.github/workflows/ensure-codex-ruleset.yaml`
- `.github/workflows/iac-lint.yaml`
- `.github/workflows/infrastructure-validate.yaml`
- `.github/workflows/release.yml`
- `.changeset/*`

Deja Groove adds mature iOS/TestFlight and Azure Function deployment files.
Kairos has the same foundation with fewer app-specific deployment pieces.
Voxa's `feature/setup-ci-hooks-actions` branch is moving toward the same structure and adds a stronger Azure bootstrap-as-code pattern.

## What Should Be Universal

These should be template-owned and reused everywhere:

- review rubrics
- PR checks workflow shape
- Codex PR review workflow shape
- changeset check
- release computation
- ruleset automation
- hook setup
- GitHub Project field/status conventions
- base CI conventions
- IaC lint/validate conventions

## What Should Be Configurable

These should be parameterized per project:

- product/app name
- repository name
- GitHub owner
- default branch
- enabled languages/runtimes
- enabled modules, such as iOS, backend, Azure Function, TestFlight
- infrastructure path and Bicep entrypoint
- Azure region
- Azure environment names
- Azure authentication profile
- required secrets and variables
- GitHub Project title and issue seed content

## What Should Stay Project-Owned

These should not be blindly overwritten by the template:

- product README content
- PRD and architecture documents
- app source code
- infrastructure resources that encode product-specific architecture
- environment-specific secret values
- issue content and roadmap content
- fastlane identifiers and Apple account values

## Update Model

The template should support both creation and drift correction:

1. Create a new repository from the template.
2. Apply the common operational layer to an existing repository.
3. Compare an existing repository against the template and report drift.
4. Update template-owned files while preserving project-owned files.

The practical implementation should include a manifest file in each target repo, for example `.project-template.yml`, recording:

- template version
- selected profile
- enabled modules
- files managed by the template
- project-specific substitutions

