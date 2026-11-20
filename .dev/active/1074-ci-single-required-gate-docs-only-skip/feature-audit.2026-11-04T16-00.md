# Feature Audit: CI single required gate (Issue #1074)

**Audit Date:** 2026-11-04
**Feature Folder:** docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074
**Base Branch:** main
**Head Branch:** bug/ci-single-required-gate at cd5923ff8330dba3afb7b970d1b5476e8e559e4d
**Work Mode:** full-bug, from the `- Work Mode: full-bug` marker in issue.md
**Audit Type:** Initial acceptance review.

## Scope and Baseline

Resolved base `main` (origin/main at 11f188d1b4f3726d854ddc00f8ad4c810138f049, which is also the merge base). Primary evidence `artifacts/pr_context.summary.txt` and secondary `artifacts/pr_context.appendix.txt`, both generated 2026-11-04 15:56:23 UTC at head cd5923ff8, so they are current. The full branch diff (43 files) was reviewed. Acceptance source for full-bug mode is spec.md `## Acceptance Criteria` only (45 checkbox items, numbered AC-01 to AC-45 below in file order). Reviewer reruns at the head: Pester 410 of 410 passed (tests/scripts/ci and tests/scripts/workflows, coverage off), pytest 92 of 92 passed, Invoke-Formatter 0 differences and PSScriptAnalyzer 0 findings on the five new PowerShell files, actionlint 0 findings on ci.yml. No pull request and no ci.yml run exist for the branch head.

## Acceptance Criteria Inventory

Source: spec.md `## Acceptance Criteria` (exact text is in spec.md; short labels here).

- AC-01: ci.yml gate job shape (name, `if: always()`, runner, permissions, pwsh step with NEEDS_JSON).
- AC-02: workflow suite asserts `needs:` equals every other job id, derived from the file.
- AC-03: workflow suite mutation cases (removed `needs:` entry, removed `always()`).
- AC-04: skippable-constant parity with job-level `if:` text.
- AC-05: module exports `Get-CiRequiredGateDecision` with five properties and no I/O.
- AC-06: docs-only pass case.
- AC-07: docs-only fails when a non-skippable job is skipped.
- AC-08: full scope passes only when all `success`; fails on any skipped.
- AC-09: `code` other than exactly `false` selects full scope.
- AC-10: `failure` result fails.
- AC-11: `cancelled` result fails.
- AC-12: unknown or null result fails.
- AC-13: `changes` not `success` fails.
- AC-14: configuration-error cases.
- AC-15: exact SummaryText.
- AC-16: entry seams `-ReadVariable` and `-OutputWriter`.
- AC-17: explicit exits, exit mapping and dot-source guard test.
- AC-18: ci.yml diff adds only the gate job.
- AC-19: CiWorkflow, CiChangeScopeWorkflow and PoshQcWorkflow suites pass unmodified.
- AC-20: no reusable-workflow diff.
- AC-21: brief CI section content.
- AC-22: six brief copies byte-identical.
- AC-23: brief contract pytest updated and passing.
- AC-24: README gate section, docs-only table, ruleset rename procedure.
- AC-25: both atomic-plan-contract copies updated; push-down contract tests pass.
- AC-26: actionlint zero findings recorded.
- AC-27: PowerShell toolchain single pass recorded.
- AC-28: line coverage >= 85% per new file from a branch-current artifact, recorded.
- AC-29: three seeded shuffles recorded.
- AC-30: no new Python file.
- AC-31: runbook section order.
- AC-32: runbook preconditions and confirmation commands.
- AC-33: runbook context-name section verified from a real run (CI-dependent).
- AC-34: runbook read-and-save command and not-committed statement.
- AC-35: runbook PUT body builder (pwsh and jq).
- AC-36: runbook web UI path and token permission.
- AC-37: runbook verification section.
- AC-38: runbook rollback and epic/** statement.
- AC-39: runbook JSON dry parse recorded; no PUT executed.
- AC-40: proof A (CI-dependent).
- AC-41: proof B (CI-dependent).
- AC-42: proof C (CI-dependent).
- AC-43: proof D (CI-dependent).
- AC-44: proof B change absent from final head (CI-dependent).
- AC-45: final head touches a non-allowlisted path and every required context is green (CI-dependent).

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC-01 | Gate job shape | PASS | ci.yml lines 117 to 145 | Read of ci.yml; WG01 | Matches every named element |
| AC-02 | needs parity | PASS | WG02 passed (11 jobs) | Reviewer Pester rerun | Expected set derived from the file |
| AC-03 | Mutation cases | PASS | WG04 passed (needs removed, always removed, always weakened) | Reviewer Pester rerun | |
| AC-04 | Skippable parity | PASS | WG03 passed | Reviewer Pester rerun | full-run-marker, npm-audit-gate, root-typescript-tests |
| AC-05 | Module surface, no I/O | PASS | RG12, RG13 passed; module read | Reviewer Pester rerun; read of CiRequiredGate.psm1 | Exports two functions |
| AC-06 | Docs-only pass | PASS | RG01 passed | Reviewer Pester rerun | |
| AC-07 | Docs-only non-skippable skipped fails | PASS | RG02 passed | Reviewer Pester rerun | |
| AC-08 | Full scope rules | PASS | RG03, RG04 passed | Reviewer Pester rerun | |
| AC-09 | Scope predicate | PASS | RG05 passed | Reviewer Pester rerun | Includes `False` |
| AC-10 | failure fails | PASS | RG06 passed | Reviewer Pester rerun | |
| AC-11 | cancelled fails | PASS | RG07 passed | Reviewer Pester rerun | |
| AC-12 | Unknown or null fails | PASS | RG08 passed | Reviewer Pester rerun | |
| AC-13 | changes not success fails | PASS | RG09 passed | Reviewer Pester rerun | |
| AC-14 | Configuration errors | PASS | RG10 passed | Reviewer Pester rerun | |
| AC-15 | Exact SummaryText | PASS | RG11 passed | Reviewer Pester rerun | |
| AC-16 | Entry seams | PASS | IG01, IG02, IG07 passed | Reviewer Pester rerun | Real variables never read |
| AC-17 | Exits and guard | PASS | IG03, IG04 passed; script lines 144 to 149 | Reviewer Pester rerun | |
| AC-18 | ci.yml adds only the gate | PASS | 30 added, 0 removed lines | `git diff` of ci.yml over the merge-base range | |
| AC-19 | Existing workflow suites unmodified and passing | PASS | No diff for the three suites; 4, 40, 15 tests passed | `git diff --stat`; reviewer Pester rerun | |
| AC-20 | No reusable-workflow diff | PASS | Only ci.yml and README.md change under .github/workflows | `git diff --stat` | |
| AC-21 | Brief CI section | PASS | Brief diff read; brief contract test passed | Reviewer pytest rerun | |
| AC-22 | Six copies identical | PASS | One SHA-256 for six files | `sha256sum` | |
| AC-23 | Brief contract test | PASS | 92 passed including the edited module | Reviewer pytest rerun | |
| AC-24 | README sections | PASS | Headings and diff read | `git diff` of README.md | Ruleset endpoint replaces branch-protection endpoint |
| AC-25 | atomic-plan-contract copies | PASS | One SHA-256 for both; push-down claude resource contracts passed | `sha256sum`; reviewer pytest rerun | |
| AC-26 | actionlint recorded | PASS | evidence/qa-gates/actionlint-ci.2026-11-04T15-50.md; reviewer rerun exit 0 | `actionlint .github/workflows/ci.yml` | |
| AC-27 | PowerShell toolchain recorded | PASS | format, pssa, pester-coverage evidence; reviewer rerun matched | Reviewer formatter, PSSA and Pester reruns | |
| AC-28 | Per-file coverage >= 85% | UNVERIFIED | evidence/qa-gates/pester-coverage.2026-11-04T15-49.md records 100% and 90%, but artifacts/pester/powershell-coverage.xml at HEAD was rewritten at 15:53 UTC by a 40-test run and reports 0 of 90 for CiRequiredGate.psm1 | Parse of the JaCoCo LINE counters | Reverted to unchecked; close from the windows-latest poshqc merged coverage of the pull-request run at S9 |
| AC-29 | Seeded shuffles recorded | PASS | evidence/qa-gates/isolation-shuffle.2026-11-04T15-51.md (seeds 11, 42, 1074) | Evidence read | Not rerun by the reviewer |
| AC-30 | No new Python file | PASS | Only one .py path in the diff, a modification | `git diff --name-only` | |
| AC-31 | Runbook section order | PASS | Headings 1 to 7 in the required order | Read of the runbook | |
| AC-32 | Runbook preconditions | PASS | Section 1 | Read of the runbook | |
| AC-33 | Runbook context name from a real run | PENDING-CI | Section 2 reads `CONTEXT-PENDING-CI-PROOF` | Read of the runbook | CI-dependent |
| AC-34 | Runbook read-and-save | PASS | Section 3 | Read of the runbook | |
| AC-35 | Runbook PUT body | PASS | Section 4; evidence/qa-gates/runbook-dry-run.2026-11-04T15-47.md | Read of the runbook and evidence | |
| AC-36 | Runbook web UI and permission | PASS | Section 4 | Read of the runbook | |
| AC-37 | Runbook verification | PASS | Section 5 | Read of the runbook | |
| AC-38 | Runbook rollback and epic/** | PASS | Sections 6 and 7 | Read of the runbook | |
| AC-39 | JSON dry parse; no PUT | PASS | evidence/qa-gates/runbook-json-parse.2026-11-04T15-47.md | Evidence read | |
| AC-40 | Proof A | PENDING-CI | No ci.yml run for the branch | None possible before the pull request exists | CI-dependent |
| AC-41 | Proof B | PENDING-CI | As AC-40 | As AC-40 | CI-dependent |
| AC-42 | Proof C | PENDING-CI | As AC-40 | As AC-40 | CI-dependent |
| AC-43 | Proof D | PENDING-CI | As AC-40 | As AC-40 | CI-dependent; observes `needs.poshqc.result` |
| AC-44 | Proof B absent from final head | PENDING-CI | As AC-40 | As AC-40 | CI-dependent |
| AC-45 | Final head full run green | PENDING-CI | As AC-40 | As AC-40 | CI-dependent |

## Summary

37 of 45 criteria PASS. Seven are CI-dependent and pending the first pull-request run (AC-33, AC-40 to AC-45). One (AC-28) is UNVERIFIED because the raw coverage artifact on disk no longer describes the recorded run; it was reverted to unchecked in spec.md and is to be closed from CI coverage. No criterion is FAIL or PARTIAL. All open items are classified awaiting_ci in the remediation inputs.

### Acceptance Criteria Status
- Source: docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/spec.md
- Total AC items: 45
- Checked off (delivered): 37
- Remaining (unchecked): 8
- Items remaining: AC-28 (per-file line coverage from a branch-current artifact), AC-33 (runbook context name and app.id from a real run), AC-40 (proof A), AC-41 (proof B), AC-42 (proof C), AC-43 (proof D), AC-44 (proof B change absent from the final head), AC-45 (final head full run with every required context green)

## Acceptance Criteria Check-off

- The executor had already checked 38 criteria. The reviewer confirmed 37 of them as PASS and left them checked; no new check-off was needed.
- AC-28 was reverted from `[x]` to `[ ]` in spec.md because the reviewer could not re-read its figures from the raw artifact at HEAD. The item's own orchestrator run should check it off at S9 after reading the per-file LINE counters of the pull-request run's merged `poshqc / PowerShell QC` coverage artifact.
- AC-33 and AC-40 to AC-45 remain unchecked as CI-dependent criteria, owned by the item's orchestrator run at S9 per acceptance-criteria-tracking `### CI-Dependent Criteria`.
