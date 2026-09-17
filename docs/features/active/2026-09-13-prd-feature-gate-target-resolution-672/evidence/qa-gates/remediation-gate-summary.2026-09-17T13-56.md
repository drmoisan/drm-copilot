# Remediation seven-gate acceptance summary

Timestamp: 2026-09-17T13-56

Task: `[P4-T9]` of `remediation-plan.2026-09-17T12-29.md`
Issue: #672. Feature-review cycle 1 remediation.

Command: this task composes no new measurement. Each row below cites the task that produced the value and the
artifact that records it; every cited artifact was confirmed present on disk by
`ls docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/`.

EXIT_CODE: 0

Output Summary:

All seven rows are present. Every row names a task identifier and an artifact path that exists on disk, and
every row carries a verdict.

## Gate 1 — formatter and analyzer

**Verdict: PASS**

| half | task | artifact | result |
| --- | --- | --- | --- |
| formatter | `[P4-T1]` | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-format.2026-09-17T13-56.md` | the `git status --porcelain --untracked-files=all` captures taken immediately before and immediately after `run_poshqc_format` are **identical**, both empty; the formatter repaired no drift |
| analyzer | `[P4-T2]` | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-analyze.2026-09-17T13-56.md` | whole-tree count **0**, evidenced by the literal `PSScriptAnalyzer passed: no findings under` quoted from the `6>&1`-captured output; seven per-file counts all **0** |

## Gate 2 — the three prd-feature suites and the new rows

**Verdict: PASS**

Task `[P4-T3]`. Artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-test.2026-09-17T13-56.md`.

`tests` = **4761**, which is the `[P0-T6]` baseline of 4758 plus the 3 nodes this remediation adds.
`errors` = **0**.

Per-identifier node counts, each expected to be exactly 1 with no child `failure` element:

| identifier | nodes | with `failure` |
| --- | --- | --- |
| `allows a repo-relative citation placed in the item worktree` | 1 | 0 |
| `denies with the ambiguity reason when a repo-relative citation places in no worktree` | 1 | 0 |
| `hands a repo-relative citation carrying a branch signal to the derivation` | 1 | 0 |
| `hands a repo-relative citation to the derivation` | 1 | 0 |
| `allows when the modelled cwd is the item worktree` | 1 | 0 |
| `denies rather than selecting the earliest candidate on an unresolved tie` | 1 | 0 |

The per-suite results are recorded by `[P2-T8]` at
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/post-change-prd-feature-suites.2026-09-17T13-56.md`:
28 / 47 / 25 with zero failures each.

## Gate 3 — the contract suite and the 17-suite batch

**Verdict: PASS**

| half | task | artifact | result |
| --- | --- | --- | --- |
| contract suite | `[P4-T6]` | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/contract-suite-unedited.2026-09-17T13-56.md` | 15 total, 15 passed, 0 failed, and `PreToolUseSchema.Contract.Tests.ps1` absent from both the anchored name-listing diff and the porcelain status |
| 17-suite batch | `[P4-T7]` | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/must-not-regress-17-suites.2026-09-17T13-56.md` | enumerated file count **17**, `TotalCount` **556** equal to `PassedCount` **556**, `FailedCount` **0**, and no file matching `enforce-orchestration-preimplementation-gate` or `enforce-epic-merge-gate` in the changed-file enumeration |

## Gate 4 — SHA-256 equality for both repository-to-bundle pairs

**Verdict: PASS**

Task `[P3-T4]`. Artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/mirror-hash-parity.2026-09-17T13-56.md`.

Both `-ceq` comparisons are **True**, with all four 64-character hash values recorded in full:

- `enforce-prd-feature-before-planner.ps1`: `D87B0E0DAA34023019630E22AD9C1C80059AEF2BF5531B3162221B30B4080B32` on both sides
- `enforce-prd-feature-before-planner-helpers.ps1`: `6529667B99D64205DB53AA43A0D895BAE164824C283E158012C6B027D82E123D` on both sides

`Compare-Object` produced **0** difference objects for each pair.

## Gate 5 — per-file line coverage at or above 85 for both production files

**Verdict: PASS**

Task `[P4-T3]`. Artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/final-qc-test.2026-09-17T13-56.md`.

| file | covered / total | line coverage | threshold |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 88 / 97 | **90.72%** | >= 85 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 60 / 62 | **96.77%** | >= 85 |

Both `sourcefile` match counts were exactly 1, so neither figure is contaminated by a bundled mirror. No
branch-coverage figure is recorded, per `.claude/rules/powershell.md` line 64.

## Gate 6 — the failing node set equality and `errors = 0`

**Verdict: PASS**

Task `[P4-T5]`. Artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/failure-set-equality.2026-09-17T13-56.md`.

Failing node count **2**, and every member is one of the two named nodes:

1. one whose `name` contains `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. one whose `name` contains `allows every registered handler for every tool name its own matcher admits`

`errors` = **0**. No member lies outside the pair, so this remediation introduced no regression. Both members
failed identically at the `[P0-T6]` pre-change baseline and neither of their suites is in the change set, as
`[P4-T6]` confirms.

## Gate 7 — the evidence-location validator

**Verdict: PASS**

Task `[P4-T8]`. Artifact
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/qa-gates/evidence-location-validation.2026-09-17T13-56.md`.

`EXIT_CODE: 0` with **no reported path**.

---

## Overall

**Seven gates, seven PASS verdicts, no FAIL.** The remediation outcome is therefore not remediation-required,
and the final-QC loop does not restart at `[P4-T1]`. `[P4-T10]` records the loop-completion statement.

Acceptance: all seven rows are present, each names a task identifier and an artifact path that exists on disk,
and each carries a verdict of `PASS` or `FAIL`. Satisfied.
