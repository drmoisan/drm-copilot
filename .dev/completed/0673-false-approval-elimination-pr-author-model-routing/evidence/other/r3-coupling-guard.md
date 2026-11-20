# Coupling Guard: AC-28 and AC-37 (issue #673, closing #672)

Timestamp: 2026-09-19T19-12

Command: `git diff --name-only b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD`; `git status --porcelain`. Each path below is tested with an exact-line match against that diff.

EXIT_CODE: 0

## `Absent:` — files this change set must not touch

| Path | Verdict |
| --- | --- |
| `.claude/hooks/hook-command-scanner.ps1` | ABSENT |
| `.claude/hooks/hook-command-invocation.ps1` | ABSENT |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | ABSENT |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | ABSENT |
| `.codex/hooks/enforce-codex-model-routing.ps1` | ABSENT |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | ABSENT |
| `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | ABSENT |

All seven are absent from the diff. Each absence carries a distinct obligation:

- The two shared command parsers are absent, so the pre-implementation gate's pathspec, option, and metacharacter restrictions are not weakened.
- `enforce-epic-merge-gate.ps1` is absent, so the epic merge gate's `pr_number` matcher is not widened as a side effect.
- `OrchestratorState.psm1` is absent, so the module the spec pins at 499 lines is unmodified; `[P7-T4]`'s line-count row asserts the same fact from the other direction.
- The Codex analogue is absent, which the research recorded as out of scope on positive evidence rather than on its filename.
- Both F1 modules are absent, so the identity module extends the library rather than modifying it, and no extraction was needed.

## `Present:` — the eight §2.7.6 paths this task can see

| Path | Verdict |
| --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | PRESENT |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | PRESENT |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | PRESENT |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | PRESENT |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | PRESENT |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | PRESENT |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | PRESENT |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | PRESENT |

All eight are present.

The ninth §2.7.6 path, `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, is deliberately **not** asserted here: no phase before `[P11-T9]` modifies it, and its exact-line match against the diff returns 0 at this point, as expected. `[P11-T9]` asserts its presence instead, pairing an anchored diff with a porcelain observation because the file is tracked and modified rather than created.

## Porcelain

`git status --porcelain` lists only paths under `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/` — this phase's own evidence artifacts and the plan's checklist state. It lists **no path outside the two feature folders**, which is the scoped form binding rule 5 requires: an empty porcelain is not a valid acceptance condition after Phase 0, because every task writes an artifact that is uncommitted when the observation is taken.

Output Summary: All three acceptance conditions hold. The seven paths that must stay out of the diff are all absent, each for a stated reason. The eight §2.7.6 paths this task can see are all present; the ninth is correctly absent until `[P11-T9]` edits it. The porcelain lists no path outside the two feature folders.
