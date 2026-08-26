# GitHub Project Template

## Standard Fields

The Deja Groove and Kairos Project v2 boards use the same field model:

- Title
- Assignees
- Status
- Labels
- Linked pull requests
- Milestone
- Repository
- Reviewers
- Parent issue
- Sub-issues progress
- Created
- Updated
- Closed
- Priority

## Standard Status Options

- Backlog
- Ready
- In Progress
- Done

## Standard Priority Options

- P0
- P1
- P2

## Template Requirement

The eventual bootstrap script should be able to:

- create a user-owned or organization-owned GitHub Project v2 board
- create the standard fields
- create standard views if the GitHub CLI/API supports the required operations
- link the repository to the Project where supported
- add seed issues if requested
- make the operation idempotent where practical

