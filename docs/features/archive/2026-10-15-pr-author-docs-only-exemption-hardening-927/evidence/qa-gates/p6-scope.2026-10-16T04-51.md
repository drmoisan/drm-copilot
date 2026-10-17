# P6-T11 Scope (issue #927, AC-22, AC-M17 helpers half, AC-M20 path-only half, AC-M21 diff half, AC-M25 diff half; loop pass 2)

Timestamp: 2026-10-16T04-51
Command: git status --porcelain
EXIT_CODE: 0
Output Summary: Every path in the branch diff against origin/main is either under FEATURE or a section 9 WRITES entry (46 entries outside FEATURE: 7 hook paths, 7 bundle copies, 2 manifests, 16 test suites, 14 #901 files). No path contains hook-command-invocation, ends with enforce-pr-author-skill-helpers.ps1 or enforce-epic-merge-gate-authorization.ps1, begins with .claude/rules/, or begins with the #901 archive folder. The only .codex/ paths are .codex/hooks/enforce-epic-merge-gate.ps1 and .codex/hooks/hook-docs-only-diff.ps1. The only pack-manifest paths are the two section 9 manifests, each numstat `1	0`. Status lists only this plan file and untracked p6- QC artifacts.

SECOND_COMMAND: git diff --name-only origin/main...HEAD
SECOND_EXIT_CODE: 0
THIRD_COMMAND: git diff --numstat origin/main...HEAD -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
THIRD_EXIT_CODE: 0

## Paths outside FEATURE, by section 9 group

- Production hooks (WRITES 1-6): .claude/hooks/hook-docs-only-diff.ps1, .claude/hooks/enforce-pr-author-skill.docs-only.ps1, .claude/hooks/enforce-pr-author-skill.ps1, .claude/hooks/enforce-epic-merge-gate-resolution.ps1, .claude/hooks/enforce-epic-merge-gate.ps1, .codex/hooks/enforce-epic-merge-gate.ps1
- Helper copies and mirrors (WRITES 7-14): .codex/hooks/hook-docs-only-diff.ps1; claude bundle hook-docs-only-diff.ps1, enforce-pr-author-skill.docs-only.ps1, enforce-pr-author-skill.ps1, enforce-epic-merge-gate.ps1, enforce-epic-merge-gate-resolution.ps1; codex bundle enforce-epic-merge-gate.ps1, hook-docs-only-diff.ps1
- Manifests (WRITES 15-16): both core.json files
- New suites (WRITES 17-21): enforce-epic-merge-gate.DocsOnly.Tests.ps1, enforce-epic-merge-gate-docs-only.Tests.ps1, claude-hooks hook-docs-only-diff.Tests.ps1, hook-docs-only-diff.MergeExemption.Tests.ps1, codex-hooks hook-docs-only-diff.Tests.ps1
- Existing suites (WRITES 22-32): the three DocsOnly suites and the eight Appendix K suites
- #901 record (WRITES 33-46): issue.md and the 13 Appendix P evidence files at the active path

## Manifest numstat

- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json: 1	0
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json: 1	0

## Exclusion checks

- contains hook-command-invocation: none
- ends with enforce-pr-author-skill-helpers.ps1: none
- ends with enforce-epic-merge-gate-authorization.ps1: none
- begins with .claude/rules/: none
- begins with docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901/: none

## Status lines

- ` M` this plan file
- `??` docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/p6-* only
