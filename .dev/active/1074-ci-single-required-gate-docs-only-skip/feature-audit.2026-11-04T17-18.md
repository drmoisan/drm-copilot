# Feature Audit: CI single required gate (Issue #1074)

**Audit Date:** 2026-11-04
**Feature Folder:** docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074
**Base Branch:** main
**Head Branch:** bug/ci-single-required-gate at f707c32b0a56c81774d6c7fbd6490a0045b5cbe8 (pull request #1077)
**Work Mode:** full-bug, from the `- Work Mode: full-bug` marker in issue.md
**Audit Type:** Re-audit after review 0 (feature-audit.2026-11-04T16-00.md, verdict AWAITING_CI).

## Scope and Baseline

Resolved base `main`; merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049 (origin/main has since advanced to 61338f51f with no path overlap and no merge conflict; `gh pr view 1077` reports MERGEABLE). Primary evidence `artifacts/pr_context.summary.txt` and secondary `artifacts/pr_context.appendix.txt`, both generated 2026-11-04 17:15:16 UTC at head f707c32b0, so they are current. The full branch diff (53 files, 18 commits) was reviewed. Acceptance source for full-bug mode is spec.md `## Acceptance Criteria` only (45 checkbox items, numbered AC-01 to AC-45 in file order). Commits after review 0 change only feature-folder files except the proof B step and its exact revert. Reviewer checks at the head: Pester 410 of 410 passed (coverage off), actionlint 0 findings, CI runs and coverage artifacts verified with `gh` (see policy-audit.2026-11-04T17-18.md).

## Acceptance Criteria Inventory

Source: spec.md `## Acceptance Criteria` (exact text is in spec.md; short labels here).

- AC-01: ci.yml gate job shape.
- AC-02: workflow suite asserts `needs:` equals every other job id.
- AC-03: workflow suite mutation cases.
- AC-04: skippable-constant parity with job-level `if:` text.
- AC-05: module exports `Get-CiRequiredGateDecision` with five properties and no I/O.
- AC-06: docs-only pass case.
- AC-07: docs-only fails when a non-skippable job is skipped.
- AC-08: full scope passes only when all `success`.
- AC-09: `code` other than exactly `false` selects full scope.
- AC-10: `failure` result fails.
- AC-11: `cancelled` result fails.
- AC-12: unknown or null result fails.
- AC-13: `changes` not `success` fails.
- AC-14: configuration-error cases.
- AC-15: exact SummaryText.
- AC-16: entry seams.
- AC-17: explicit exits, exit mapping and dot-source guard test.
- AC-18: ci.yml diff adds only the gate job.
- AC-19: existing workflow suites pass unmodified.
- AC-20: no reusable-workflow diff.
- AC-21: brief CI section content.
- AC-22: six brief copies byte-identical.
- AC-23: brief contract pytest updated and passing.
- AC-24: README sections.
- AC-25: both atomic-plan-contract copies updated.
- AC-26: actionlint zero findings recorded.
- AC-27: PowerShell toolchain single pass recorded.
- AC-28: line coverage >= 85% per new file from a branch-current artifact.
- AC-29: three seeded shuffles recorded.
- AC-30: no new Python file.
- AC-31 to AC-39: runbook sections, commands, dry parse, no PUT executed (AC-33 CI-dependent).
- AC-40 to AC-43: proofs A to D (CI-dependent).
- AC-44: proof B change absent from final head (CI-dependent).
- AC-45: final head touches a non-allowlisted path and every required context is green (CI-dependent).

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|---|
| AC-01 | Gate job shape | PASS | ci.yml gate job; WG01 | Read of ci.yml; reviewer Pester rerun | Unchanged since review 0 |
| AC-02 | needs parity | PASS | WG02 passed | Reviewer Pester rerun | |
| AC-03 | Mutation cases | PASS | WG04 passed | Reviewer Pester rerun | |
| AC-04 | Skippable parity | PASS | WG03 passed | Reviewer Pester rerun | |
| AC-05 | Module surface, no I/O | PASS | RG12, RG13 passed | Reviewer Pester rerun | |
| AC-06 | Docs-only pass | PASS | RG01 passed; proof D on a runner | Reviewer Pester rerun; `gh run view 41874737526` | |
| AC-07 | Docs-only non-skippable skipped fails | PASS | RG02 passed | Reviewer Pester rerun | |
| AC-08 | Full scope rules | PASS | RG03, RG04 passed | Reviewer Pester rerun | |
| AC-09 | Scope predicate | PASS | RG05 passed | Reviewer Pester rerun | |
| AC-10 | failure fails | PASS | RG06 passed; proof B on a runner | Reviewer Pester rerun; `gh run view 41868374284 --json jobs` | |
| AC-11 | cancelled fails | PASS | RG07 passed | Reviewer Pester rerun | |
| AC-12 | Unknown or null fails | PASS | RG08 passed | Reviewer Pester rerun | |
| AC-13 | changes not success fails | PASS | RG09 passed | Reviewer Pester rerun | |
| AC-14 | Configuration errors | PASS | RG10 passed | Reviewer Pester rerun | |
| AC-15 | Exact SummaryText | PASS | RG11 passed; real summaries in proofs A to D match the format | Reviewer Pester rerun | |
| AC-16 | Entry seams | PASS | IG01, IG02, IG07 passed | Reviewer Pester rerun | |
| AC-17 | Exits and guard | PASS | IG03, IG04 passed | Reviewer Pester rerun | |
| AC-18 | ci.yml adds only the gate | PASS | 30 added, 0 removed lines | `git diff 11f188d1b HEAD -- .github/workflows/ci.yml` | |
| AC-19 | Existing workflow suites unmodified and passing | PASS | No diff for the three suites; passed in reviewer rerun and CI | `git diff --stat`; reviewer Pester rerun | |
| AC-20 | No reusable-workflow diff | PASS | Only ci.yml and README.md differ under .github/workflows; proof B step reverted | `git diff --name-only 11f188d1b HEAD -- .github/workflows` | |
| AC-21 | Brief CI section | PASS | Unchanged since review 0 | Review 0 pytest rerun; CI quality-checks7 success | |
| AC-22 | Six copies identical | PASS | Unchanged since review 0 (one SHA-256) | `git diff --name-only cd5923ff8 HEAD` | |
| AC-23 | Brief contract test | PASS | Review 0 rerun 92 passed; CI quality-checks7 success | Evidence read | |
| AC-24 | README sections | PASS | Unchanged since review 0 | `git diff` of README.md | |
| AC-25 | atomic-plan-contract copies | PASS | Unchanged since review 0 | `git diff --name-only cd5923ff8 HEAD` | |
| AC-26 | actionlint recorded | PASS | evidence/qa-gates/actionlint-ci.2026-11-04T15-50.md; reviewer rerun exit 0 | `actionlint .github/workflows/ci.yml` | |
| AC-27 | PowerShell toolchain recorded | PASS | format, pssa, pester-coverage evidence | Evidence read; reviewer Pester rerun | |
| AC-28 | Per-file coverage >= 85% | PASS | CiRequiredGate.psm1 90 of 90 (100%), Invoke-CiRequiredGate.ps1 27 of 30 (90%) in `powershell-coverage.xml` of run 41871788989; evidence/qa-gates/coverage-ci-artifact.2026-11-04T17-14.md | `gh run download 41871788989 -n poshqc-test-results`; JaCoCo LINE parse | The run head 23dd72202 carries the same production files as the branch head, so the artifact is branch-current |
| AC-29 | Seeded shuffles recorded | PASS | evidence/qa-gates/isolation-shuffle.2026-11-04T15-51.md | Evidence read | |
| AC-30 | No new Python file | PASS | One .py path in the diff, a modification | `git diff --name-only --diff-filter=A` | |
| AC-31 | Runbook section order | PASS | Sections 1 to 7 in order | Read of the runbook | |
| AC-32 | Runbook preconditions | PASS | Section 1 | Read of the runbook | |
| AC-33 | Runbook context name from a real run | PASS | Section 2: `CI Required Gate`, `app.id` 15368, verified on run 41864628204 | Read of the runbook; proof A check-runs fields | |
| AC-34 | Runbook read-and-save | PASS | Section 3 | Read of the runbook | |
| AC-35 | Runbook PUT body | PASS | Section 4; runbook-dry-run evidence | Evidence read | |
| AC-36 | Runbook web UI and permission | PASS | Section 4 | Read of the runbook | |
| AC-37 | Runbook verification | PASS | Section 5 | Read of the runbook | |
| AC-38 | Runbook rollback and epic/** | PASS | Sections 6 and 7 | Read of the runbook | |
| AC-39 | JSON dry parse; no PUT | PASS | runbook-json-parse evidence | Evidence read | |
| AC-40 | Proof A | PASS | Run 41864628204, pull_request, head e3ef692e5, success; every row success | `gh run view 41864628204 --json headSha,event,conclusion`; PROOFA | |
| AC-41 | Proof B | PASS | Run 41868374284, head 16be68a10, failure; only `docs-validation` and `CI Required Gate` non-success | `gh run view 41868374284 --json jobs` | |
| AC-42 | Proof C | PASS | Run 41871788989, head 23dd72202, full run, all 23 jobs success | `gh run view 41871788989 --json jobs` | |
| AC-43 | Proof D | PASS | Run 41874737526, head 914ffb0c2, success; gate rows `full-run-marker`, `npm-audit-gate`, `root-typescript-tests` skipped, `poshqc` success | `gh run view 41874737526 --log --job 126731576072` | |
| AC-44 | Proof B absent from final head | PASS | No `_docs-validation.yml` diff against the base at f707c32b0 | `git diff --name-only 11f188d1b HEAD -- .github/workflows/_docs-validation.yml` | Re-confirm at S9 if the final head changes |
| AC-45 | Final head full run green | PENDING-CI | Head f707c32b0 is docs-only (run 41875760445 skipped the shard, root-typescript-tests and NPM Audit Gate jobs); `mergeStateStatus` BLOCKED | `gh run view 41875760445 --json jobs`; `gh pr view 1077` | Orchestrator-owned final commit and check-off at S9 (plan line 25) |

## Summary

44 of 45 criteria PASS. AC-45 is CI-dependent and pending the final-head full run that the plan assigns to the orchestrator at S9; it is classified awaiting_ci in remediation-inputs.2026-11-04T17-18.md. No criterion is FAIL, PARTIAL or UNVERIFIED. Review 0 open items AC-28, AC-33 and AC-40 to AC-44 are now verified.

### Acceptance Criteria Status
- Source: docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/spec.md
- Total AC items: 45
- Checked off (delivered): 44
- Remaining (unchecked): 1
- Items remaining: AC-45 (the final pull request head commit touches at least one path outside the `config/ci-docs-only-paths.json` allowlist, and its full `ci.yml` run reports every context currently required by ruleset 15241672 as `success`, together with `CI Required Gate`)

## Acceptance Criteria Check-off

- The executor checked AC-28, AC-33 and AC-40 to AC-44 after review 0. The reviewer independently verified each against the GitHub API and the downloaded CI coverage artifact, evaluated them PASS, and left them checked; no reviewer edit to spec.md was needed.
- AC-45 remains unchecked as a CI-dependent criterion, owned by the item's orchestrator run at S9 per acceptance-criteria-tracking `### CI-Dependent Criteria`.
