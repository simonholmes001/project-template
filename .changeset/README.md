# Changesets

Add a changeset for releasable changes to the project template.

Use this format:

```md
---
"project-template": patch
---

Short description of the user-facing or operational change.
```

Use `patch`, `minor`, or `major` according to the release impact:

- **patch**: Bug fixes, documentation updates, minor improvements to existing features
- **minor**: New template features, new scripts, new workflows, non-breaking enhancements
- **major**: Breaking changes to template structure, generator behavior, or bootstrap process

## Examples

**Patch** - Documentation or minor improvements:
```md
---
"project-template": patch
---

Fix typo in bootstrap script documentation
```

**Minor** - New features:
```md
---
"project-template": minor
---

Add Azure Key Vault deployment template and bootstrap script
```

**Major** - Breaking changes:
```md
---
"project-template": major
---

Restructure template directory to support multi-runtime projects (breaking change for existing consumers)
```
