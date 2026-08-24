# QA gate — Scope-boundary check (AC-13) (#501)

Timestamp: 2026-08-22T00-20

Task: [P5-T5]

Command:

```powershell
$union = @(git diff --name-only main...HEAD) +
         @(git diff --name-only --cached) +
         @(git diff --name-only) +
         @(git ls-files --others --exclude-standard) |
         Sort-Object -Unique
```

The union of committed, staged, unstaged, and untracked paths is used rather than `git diff --name-only main...HEAD` alone, because the commit-only form reports nothing while the migration is uncommitted and therefore cannot fail.

EXIT_CODE: 0

## Union cardinality

```
union-count: 102
```

The union is non-empty, so the check observed the migration. Its composition:

- 27 files under `.claude/` (24 migrated PreToolUse hooks, the two new dot-sourced helper siblings `enforce-pr-author-skill-helpers.ps1` and `enforce-parallel-cohort-barrier-helpers.ps1`, and the new shared module `.claude/lib/hook-payload/HookPayload.psm1`).
- 27 byte-identical mirror copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- 33 Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/claude-lib/`, including three new suites (`PreToolUsePayload.Contract.Tests.ps1`, `enforce-pr-author-skill.Payload.Tests.ps1`, `enforce-completion-consistency.Payload.Tests.ps1`, `enforce-parallel-cohort-barrier.Payload.Tests.ps1`, `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1`).
- The remainder are this feature's own documents and evidence artifacts under `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`.

## Out-of-scope filter 1 — any path under `.codex/hooks/`

```
codex-rows: 0
```

No row. The Codex hook surface is untouched.

## Out-of-scope filter 2 — the eight SubagentStop validators, production or test paths

Filenames matched: `validate-discovery-artifact-gate.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`, `validate-orchestrator-output.ps1`, `validate-planner-output.ps1`, `validate-pr-author-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, and their `.Tests.ps1` counterparts.

```
validator-rows: 0
```

No row. All eight SubagentStop validators and their suites are byte-unchanged.

## Incidental working-tree correction recorded here

During an unrelated diagnostic step earlier in this task's phase, a `git stash pop` restored a pre-existing, unrelated stash entry (`potential-bug-doc: poshqc-bundled-settings-drift (issue #303)`) into the working tree, which put `docs/features/potential/promoted/2026-07-04-poshqc-bundled-settings-drift.md` into the first union measurement (103 rows). The entry was re-stashed with `git stash push -u` and the file removed from the working tree, restoring the stash list to its three original entries and the union to 102 rows. That file is unrelated to issue #501 and is not part of this change set. The union figure above is the corrected measurement.

Output Summary: Union of 102 paths, non-empty, so the check observed the migration. Both out-of-scope filters return zero rows: no path under `.codex/hooks/` and none of the eight SubagentStop validators (production or test) appears in the change set. AC-13 satisfied.
