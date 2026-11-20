# File-Set Discipline — Changed-Path Union (issue #516)

Timestamp: 2026-08-24T16-43
Command: `git diff --name-only fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` and `git status --porcelain --untracked-files=all`, unioned
EXIT_CODE: 0

Baseline substitution applies: the plan names `c308dd92`, which is now an ancestor of `main` after this branch was rebased following the merge of PR #536. The merge-base `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24` is used instead. Full reasoning in `evidence/baseline/baseline-branch-and-fileset.2026-08-23T23-25.md`.

Why the union rather than the diff alone: `git diff` against a commit reports tracked files only, so the two newly created test suites are invisible to it until they are committed. Using the union makes them visible without requiring a commit, so this check does not depend on orchestrator-side commit timing.

## The Complete Changed-Path Union — 33 paths

### The seven declared source paths (all present)

| # | Path | State |
| --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | tracked-modified |
| 2 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | tracked-modified |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | tracked-modified |
| 4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | tracked-modified |
| 5 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | **untracked** (new) |
| 6 | `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | **untracked** (new) |
| 7 | `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/spec.md` | tracked-modified |

All seven declared paths are present. Paths 5 and 6 are visible only through the `git status` half of the union, which is precisely why the union is used.

### This item's own planning documents — 3 paths

| Path | State |
| --- | --- |
| `docs/features/active/2026-08-23-.../issue.md` | tracked-modified |
| `docs/features/active/2026-08-23-.../plan.2026-08-23T23-25.md` | tracked-modified |
| `docs/features/active/2026-08-23-.../research/2026-08-23T23-40-preimplementation-gate-absolute-path-516-research.md` | tracked-modified |

`issue.md`, `spec.md`, and the research artifact are tracked-modified relative to the merge-base because the single preparation commit `9c12d20a` added them. The plan file is modified in the working tree by this executor's checkbox ticks. None is a source change of this item.

### This item's `evidence/` tree — 23 paths, all untracked

```text
evidence/baseline/baseline-branch-and-fileset.2026-08-23T23-25.md
evidence/baseline/baseline-four-copy-hashes.2026-08-23T23-25.md
evidence/baseline/baseline-poshqc-analyze.2026-08-23T23-25.md
evidence/baseline/baseline-poshqc-format.2026-08-23T23-25.md
evidence/baseline/baseline-poshqc-test.2026-08-23T23-25.md
evidence/baseline/baseline-powershell-coverage.2026-08-23T23-25.md
evidence/baseline/baseline-pytest-pushdown-parity.2026-08-23T23-25.md
evidence/other/batch-budget-reset.2026-08-23T23-25.md
evidence/other/phase0-instructions-read.2026-08-23T23-25.md
evidence/qa-gates/coverage-delta.2026-08-23T23-25.md
evidence/qa-gates/final-clean-pass.2026-08-23T23-25.md
evidence/qa-gates/final-poshqc-analyze.2026-08-23T23-25.md
evidence/qa-gates/final-poshqc-format.2026-08-23T23-25.md
evidence/qa-gates/final-poshqc-test.2026-08-23T23-25.md
evidence/qa-gates/final-powershell-coverage.2026-08-23T23-25.md
evidence/qa-gates/final-pytest-pushdown-parity.2026-08-23T23-25.md
evidence/qa-gates/final-typecheck-not-applicable.2026-08-23T23-25.md
evidence/qa-gates/four-copy-parity-hashes.2026-08-23T23-25.md
evidence/qa-gates/synthetic-path-constant-audit.2026-08-23T23-25.md
evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md
evidence/regression-testing/pass-after-claude-batch.2026-08-23T23-25.md
evidence/regression-testing/pass-after-codex-batch.2026-08-23T23-25.md
evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md
```

All are prefixed `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/`. This artifact itself, `evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md`, is written after the union was captured and belongs to the same tree.

## Acceptance Conditions

| Condition | Result |
| --- | --- |
| All seven declared paths present in the union | **Yes** — enumerated above |
| Every other path lies under this item's feature folder | **Yes** — all 26 others are under `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/` |
| No path under `.claude/rules/` | **Yes** — zero |
| No path under `.github/instructions/` | **Yes** — zero |
| No `quality-tiers.yml` | **Yes** — zero |
| No path named under `PRE-EXISTING FORMATTER DRIFT` in [P0-T8] or [P4-T1] | **Yes** — both sets are empty, so no restoration was required and no such path could appear |
| No path outside the two permitted sets | **Yes** |
| No declared path missing | **Yes** |

## Paths Deliberately Absent From the Union

- **`.claude/state/powershell-batch-budget.default.json`** — gitignored (`.gitignore:68`), created and removed repeatedly by the batch-budget hook during this session. Cannot appear in the union and does not.
- **`artifacts/pester/*` and `artifacts/orchestration/orchestrator-state.json`** — gitignored. Every Pester result, coverage output, and the orchestration checkpoint are outside the diff by construction.
- **The six run-only files** — verified absent by [P5-T2].

## [P5-T2] Run-Only Files Are Absent From the Union

Timestamp: 2026-08-24T16-45
Command: membership test of the six run-only paths against the union, recomputed programmatically as `git diff --name-only fb3e1f33` unioned with the path column of `git status --porcelain --untracked-files=all`
EXIT_CODE: 0

```text
union size: 34
absent   tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
absent   tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1
absent   tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
absent   tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
absent   tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
absent   tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
run-only files present in union: 0
```

**Acceptance condition — zero of those six paths present: satisfied.**

All six were executed as verification legs and none was edited:

| Run-only file | Executed at | Result |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | [P2-T4], [P4-T4] | 35/35 pass |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | [P2-T4], [P4-T4] | 15/15 pass |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | [P3-T5], [P4-T4] | 43/43 pass |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | [P3-T5], [P4-T4] | 56/56 pass |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | [P4-T4] | 27/27 pass |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | [P0-T12], [P2-T5], [P4-T5] | 10/10 pass |

The union size reported here is 34 rather than the 33 enumerated above because this artifact file itself was created between the two captures. The one added path is `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516/evidence/qa-gates/file-set-discipline.2026-08-23T23-25.md`, which lies under this item's feature folder and therefore satisfies the same acceptance conditions as every other evidence artifact.

## Note on Timing

This union was captured before [P5-T5] ticks the acceptance-criteria checkboxes in `spec.md`. That edit changes `spec.md` only, which is declared path 7 and is already in the union as tracked-modified. It cannot add a path to the union or remove one, so the verdict above is unaffected.

Output Summary: The changed-path union contains 33 paths. All seven declared source paths are present, including the two new test suites, which are untracked and visible only through the `git status` half of the union. Every one of the other 26 paths lies under this item's own feature folder — 3 planning documents and 23 evidence artifacts, none of which is a source change. The union contains no path under `.claude/rules/`, none under `.github/instructions/`, no `quality-tiers.yml`, no formatter-drift path (both drift sets are empty), and no path outside the two permitted sets. File-set discipline holds.
