# R1 QC Scope (Issue #927, AC-22, AC-M21 diff half, AC-M25 diff half, rule R1-13; loop pass 2)

Timestamp: 2026-10-16T08-45
Command: git status --porcelain
EXIT_CODE: 0
Output Summary: Every status line and every path changed since R1_START_HEAD is in section 13 or under the feature folder. The branch diff against origin/main lists no hook-command-invocation file, no enforce-pr-author-skill-helpers.ps1, nothing under .claude/rules/, .github/instructions/, or the #901 archive path; the only .codex/ paths are the gate and the helper; the only pack manifests are the two named by spec Design item 13.

STATUS: 9 untracked files, all under docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/ (this loop pass's artifacts)

Command 2: git diff --name-only 8ee8f25311f6bbc3777b0068100cf497bd6a7a03 HEAD
EXIT_CODE_2: 0
R1_DIFF_OUTSIDE_FEATURE (all members of section 13):
.claude/hooks/enforce-epic-merge-gate.ps1
.claude/hooks/hook-docs-only-diff.ps1
.codex/hooks/enforce-epic-merge-gate.ps1
.codex/hooks/hook-docs-only-diff.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1
tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1
tests/scripts/claude-hooks/hook-docs-only-diff.BoundedNative.Tests.ps1
tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1
tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1
tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1
R1_DIFF_FEATURE_PATHS: all remaining paths are under docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/ (spec.md, plan.2026-10-15T07-41.md, remediation-plan.2026-10-16T05-25.md, research/research-addendum-merge-gate.2026-10-15T19-46.md, and new evidence files)
NOTE: tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 is absent from this diff because the CR-5 fallback restored it byte-identically.

Command 3: git fetch origin main
EXIT_CODE_3: 0

Command 4: git diff --name-only origin/main...HEAD
EXIT_CODE_4: 0
CHECK hook-command-invocation: 0 paths
CHECK ends with enforce-pr-author-skill-helpers.ps1: 0 paths
CHECK begins with .claude/rules/: 0 paths
CHECK begins with .github/instructions/: 0 paths
CHECK begins with docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901/: 0 paths
CHECK .codex/ paths: .codex/hooks/enforce-epic-merge-gate.ps1, .codex/hooks/hook-docs-only-diff.ps1
CHECK pack-manifests/core.json paths: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json, extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json
