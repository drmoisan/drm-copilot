# Code Review: Owner-Directive Pass-Down to Executing Agents (Issue #1157)

**Review Date:** 2026-11-13
**Branch:** `feature/owner-directive-pass-down-1157` @ `b632f1759505988239851afef95043926f0224fb` (no PR open yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db` (base unmoved at review time)
**Scope:** full branch diff, 144 files; this re-audit reads the cycle-1 changes (`621a6b83d..b632f1759`: 2 production hooks with bundle copies, 15 test suites, feature-folder evidence and records) line by line and re-checks the rest of the branch for regressions against the initial review `code-review.2026-11-13T14-04.md`.

## Executive Summary

Cycle 1 resolves F1, F2, and F3.

- F1: `validate-orchestrator-output-owner-pass-down.ps1` reads its four sources through `Get-OrchestratorOutputOwnerPassDownSourceText`, which calls the stop hook's existing seam `Get-CheckpointFileContent`. The sibling's own read function is gone, so the discovery guard no longer requires a baseline mock for it, and the AC-29 suite equals the merge base.
- F2: a coverage-enabled pytest gate wrote `artifacts/python/lcov.info` (97.11% lines, 94.37% branches).
- F3: the ledger path test uses `OrdinalIgnoreCase` for both operands, pinned by two rows that failed before the change.

No blocking finding remains. Two non-blocking items are added (CR4, CR5); CR1 to CR3 carry over unchanged.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (F1) | `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1`; `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` | `Get-OrchestratorOutputOwnerPassDownSourceText` and its four call sites | The sibling no longer defines a file-read seam; the AC-29 suite has an empty diff against the merge base and passes 22/0; the discovery guard passes 531/0. | None. | AC-29 "pass without edits" is met as written. | Reviewer `git diff --stat 1d62aa292..HEAD` over the three AC-29 suites (empty); `git grep Read-OrchestratorOutputOwnerPassDownText` (no match); `evidence/qa-gates/pester-final.2026-11-13T15-48.md` |
| Resolved (F2) | Python evidence | `artifacts/python/lcov.info` | The artifact exists; LF 35355, LH 34334, BRF 13424, BRH 12668. | None. | Coverage verification for a language with changed files is satisfied. | Reviewer parse of the lcov file; `evidence/qa-gates/pytest-final.2026-11-13T15-55.md` |
| Resolved (F3) | `.claude/hooks/enforce-owner-directive-pass-down.ps1` (and bundle copy) | `Get-OwnerDirectivePassDownDecision` ledger branch | Both operands now compare with `[System.StringComparison]::OrdinalIgnoreCase`; the title-case and upper-case ledger rows deny with `OWNER_DIRECTIVE_LEDGER_WRITE_DENIED`. | None. | Spec D5 and AC-27 hold on a case-insensitive file system. | `evidence/regression-testing/fail-before.F3.2026-11-13T14-45.md` (both rows failed before the fix, no other case failed); final gate 83/0 |
| Minor (CR1) | `.claude/hooks/enforce-owner-directive-pass-down.ps1` | `Resolve-OwnerDirectivePassDownAck` | Per-call resolution cost for acknowledgement-set agents, disclosed in the spec. Unchanged. | No change in this item; #1159 should measure this hook. | Carried over from the initial review. | Spec `## Known Limitations` |
| Minor (CR2) | branch history | commit `a4e992584` | The main implementation commit carries a pause subject. Unchanged. | Describe the content in the PR body or squash-merge. | `git log` and blame read better with a descriptive subject. | `git show --stat a4e992584` |
| Info (CR3) | `evidence/baseline/pester-baseline.2026-11-10T04-02.md` | Phase 0 baseline | The Phase 0 Pester run overlapped a module write of this item. Unchanged; cycle 1 compares with the same baseline. | None. | Recorded so the baseline is not cited as clean pre-change evidence. | The artifact's own failure note |
| Minor (CR4) | `.claude/hooks/validate-orchestrator-output-owner-pass-down.ps1` | `Get-OrchestratorOutputOwnerPassDownSourceText`, self-equal rule | The helper treats a source whose content is ordinally equal to the checkpoint under validation as absent. The rule exists so that path-agnostic `Get-CheckpointFileContent` mocks in existing stop-hook suites keep the decision the removed null mock gave. In production the ledger, parent checkpoint, and child checkpoint are different files from the checkpoint, so the rule changes one decision only: a ledger byte-identical to the checkpoint is now absent instead of `OWNER_DIRECTIVE_LEDGER_INVALID`. Subagent writes to the ledger are denied by the PreToolUse ledger guard, so only the main session could produce that state. | No change in this item. If a later item touches these suites, replace their path-agnostic mocks with path-keyed ones and drop the rule. | A production branch shaped by test mocks is a small design cost; the effect is narrow, documented in the helper's `.DESCRIPTION` and the plan's premise corrections, and covered by two rows. | Helper source at head; `source read seam (F1)` rows |
| Info (CR5) | `evidence/qa-gates/phase-gate.P1.2026-11-13T15-34.md` | correction bullet | The correction cites `task-check.P1-T7.2026-11-13T14-57.md`; the committed file is `task-check.P1-T7.2026-11-13T14-58.md`. The content of the correction (the six filter rows) is accurate. | None; evidence is append-only, and this review records the correct stamp. | Keeps the citation chain traceable without editing evidence. | `ls evidence/other/task-check.P1-T7.*` |

No covered file in the diff is at or above 700 logical lines (largest: `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`, 536), so no file-size Warning row applies, and `config/file-size-baseline.json` is not in the diff.

## Detailed Review

### F3: ledger path comparison

The ledger branch now reads `[string]::Equals($path, 'artifacts/orchestration/owner-directives.jsonl', OrdinalIgnoreCase) -or $path.EndsWith('/artifacts/orchestration/owner-directives.jsonl', OrdinalIgnoreCase)`. Lower-case paths keep the same decision, so every existing `ledger guard (AC-27)` row is unaffected. The change only widens the deny set. The two new rows use forward-slash synthetic paths, so the decision is a pure string comparison and behaves the same on the Linux hook-suite job. The row names carry a `(<Label>)` suffix because the repository's test-name uniqueness guard folds case; the phase gate records the first-pass failure and the fix.

### F1: source reads through the stop-hook seam

`Get-OrchestratorOutputOwnerPassDownSourceText` calls `Get-CheckpointFileContent -Path` inside `try` and returns `$null` for a thrown read, a `$null` result, `Exists` false, blank content, or content equal to the checkpoint text. `Get-CheckpointFileContent` (defined in `validate-orchestrator-output.ps1`, which dot-sources the sibling) returns `Exists = $false` for a missing path and reads with `Get-Content -Raw -ErrorAction Stop`, so the production behavior for missing and unreadable files matches the removed `File.Exists` and `ReadAllText` pair. All four call sites (item ledger, parent checkpoint, parent ledger, child checkpoint) pass the checkpoint text. The sibling holds no `Get-Content`, `ReadAllText`, or `ReadAllLines` token, which is what the discovery guard inspects.

The new rows discriminate. Each absent-outcome row would return non-null content if its branch were removed; the distinct-content row pins the return value; the parent-ledger row asserts a null decision for an epic checkpoint with a valid directive and exactly one read; and H14 in `validate-orchestrator-output.TargetWorktree.Tests.ps1` failed before the routing change (`fail-before.F1.2026-11-13T14-53.md`: 17 passed, 1 failed, H14 only) and passes after it.

### Filter correction outside the planned file set

Six `Should -Invoke Get-CheckpointFileContent -Times 1 -Exactly -ParameterFilter { $Path -eq $path }` assertions in `.WorktreeResolution` and `.MutationRejection` matched every call, because PowerShell resolves `$path` inside the filter to the mock's `$Path` parameter. Once the ledger read reached the same seam, five of them counted two calls and failed. The executor renamed the outer variable to `$expectedPath`, so the filters now compare against the checkpoint path and count only the checkpoint read. Assertion values are unchanged. This is a correct fix of a latent non-discriminating assertion; it was reported for escalation in the task check and listed in the self-review.

### Coverage of changed lines

The reviewer read the JaCoCo line elements of both edited hooks. The changed line in the enforce hook and every line of the new helper and its call sites have no missed-only line; the sibling's remaining uncovered lines (the default resolver bodies and unchanged branches) predate the cycle. The sibling rose from 92.86% to 94.62%.

### Mirrors and documentation

Both edited hooks were changed in the same commits as their bundle copies, and `bundle-parity.2026-11-13T15-56.md` lists 23 pairs with 0 unequal. No skill, rule, brief, or spec text names the removed function.

## Verification Performed

- `git -C <item worktree> diff 621a6b83d..HEAD` over `.claude` and `tests`.
- `git -C <item worktree> diff --stat 1d62aa292..HEAD` over the three AC-29 suites (empty) and `git grep` for the removed function (no match).
- Read of `Get-CheckpointFileContent` in `validate-orchestrator-output.ps1` to confirm missing and unreadable file behavior.
- Parse of `artifacts/pester/powershell-coverage.xml` (root and seven production files, plus missed line elements of the two edited hooks) and of `artifacts/python/lcov.info`.
- Artifact modification times against the last production commit `503b5c3f2`.
- Logical line counts (`awk 'END{print NR}'`) of every covered file in the diff.
- `check_quality_tiers.py` and `validate_evidence_locations.py` against the item worktree: both clean.
- `git fetch origin main` and `git merge-tree --write-tree origin/main HEAD`: no drift, no conflict.

The owner's parallel-only rule forbids single-file Pester runs, so reviewer mutant runs were not made; discrimination was judged from the fail-before records (F1 and F3) and by reading each new row against the helper source.

## Verdict

**PASS.** Zero blocking findings. F1 to F3 are resolved. CR1 to CR5 are non-blocking.
