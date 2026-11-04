---
name: sibling-library-wide-guards-after-integration-merge
description: After an epic integration merge, a sibling's library-wide set-equality guard (e.g. 1023 DocsWriteBoundary) can fail on this item's new modules; plan dispositions predate it, and the Bash tool shell is zsh (no word splitting)
metadata:
  type: project
---

Observed 2026-11-04 on issue 1024 (epic documentation-estate-tooling): after the orchestrator merged sibling 1023 into the branch, the 1023 suite `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` asserted across every `.claude/lib/docs` file that only `Invoke-DocsArtifactWrite` invokes `& $WriteText`. 1024's planned `Invoke-DocsReferencePageWrite` did the same, so the final Pester gate failed. The plan's [P0-T4] dispositions and `## Artifact Classification` table predated the guard.

Resolution used: extend that one test's expected set to name both boundaries (keeps set equality), report it as a deviation, and add an executor-marked classification row so the "classification lists every edited file" AC holds. Renaming the parameter to dodge the guard was rejected as evasion.

**Why:** sibling suites written before later children land often scope guards to the whole library, not to their own modules.

**How to apply:** after any integration merge mid-run, grep the merged sibling suites for library-wide `Should -Be @(...)` over all files under the shared lib before the QA loop, and plan the fix and deviation record early. Also: the Bash tool runs zsh, so `for f in $(cmd)` or `for f in $files` does not word-split; use a PowerShell helper or `while read` for file lists.
