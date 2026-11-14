# Code Review: CI single required gate (Issue #1074)

**Review Date:** 2026-11-04
**Reviewer:** feature-review
**Feature Folder:** docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074
**Feature Folder Selection Rule:** The caller named the folder; its suffix matches issue #1074 and it holds the primary changed scoping documents.
**Base Branch:** main (merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049)
**Head Branch:** bug/ci-single-required-gate at cd5923ff8330dba3afb7b970d1b5476e8e559e4d
**Review Type:** Initial full feature-versus-base review.

## Executive Summary

The branch adds one aggregate job, `ci-required-gate` (`CI Required Gate`), to `.github/workflows/ci.yml`. The job needs every other `ci.yml` job, runs under `if: always()`, and passes `toJSON(needs)` through `env:` to `scripts/ci/Invoke-CiRequiredGate.ps1`, which delegates the decision to the pure module `scripts/ci/CiRequiredGate.psm1`. The decision logic matches the spec decision table: it fails closed on blank or malformed input, on any result outside `success` and `skipped`, on a non-`success` `changes` job, and accepts `skipped` only for `full-run-marker`, `root-typescript-tests` and `npm-audit-gate` and only when `code` is exactly `false`. The workflow pin derives the expected `needs:` set from the file and proves, with in-memory mutations, that it detects a removed entry and a removed `always()`. Reviewer reruns confirm the format, lint, test and actionlint results.

No autonomous correctness, security or maintainability defect was identified. The one blocking item is the repository rule that a modified workflow needs a green run at the branch head; no run exists yet because no pull request exists and the Codespace token cannot dispatch workflows. The coverage and CI-dependent acceptance waits are recorded in the policy audit and the feature audit.

**Top remaining uncertainty:** `needs.poshqc.result` on a docs-only run is expected to be `success` (the aggregator runs with gated steps); proof step D in the plan observes it. If it is `skipped`, the gate is red on docs-only heads and the design needs a remediation cycle, as spec.md Risks & Mitigations already states.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | .github/workflows/ci.yml | ci-required-gate job (modified-workflow-needs-green-run) | No ci.yml run exists for head cd5923ff8; the modified workflow has no green-run evidence | Open the pull request, let ci.yml run on the final head, and record the run under evidence/other/ (plan Phase 7) | The feature-review-workflow rule requires green-run evidence for any change under .github/workflows/; classified awaiting_ci | `git diff --name-only` lists .github/workflows/ci.yml; no pull request exists for the branch |
| Low | scripts/ci/CiRequiredGate.psm1 | Get-CiRequiredGateDecision, docs-only presence check | Presence of the eight non-skippable jobs is checked only in docs-only scope; in full scope a needs object lacking, for example, `poshqc` passes with one row fewer | Optionally apply the presence check in both scopes so an absent key is red regardless of scope | Fail-closed consistency; the runner always emits every `needs:` key and WG02 pins the `needs:` list, so the gap is not reachable from the committed workflow | Lines 209 to 214 of CiRequiredGate.psm1; spec decision table names only `changes`, `docs-validation` and the skippable set as configuration errors |
| Info | tests/scripts/dev_tools/test_execution_environment_brief_contracts.py | `_REQUIRED_CONTEXTS` | Generator expansions (`_OS`, version and manifest loops) were used to keep the module at or below 500 lines; a flat literal list reads more directly against the ruleset | No change required; consider a flat literal if the module is later split | Readability of a pinned context list | File is 497 logical lines; evidence/other/preflight-fixes.2026-11-04T15-23.md fix 5 |
| Info | docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/runbook/ruleset-single-required-gate.md | Section 2 | The gate context name and `app.id` read `CONTEXT-PENDING-CI-PROOF` | Replace both values from the proof A run before merge | Tracked by the CI-dependent spec criterion for the runbook context-name section | Runbook line 27 |

No covered file in the branch diff reaches the 700-line advisory tier or the 800-line hard limit (logical line counts: 229, 149, 336, 169, 149 and 497), and `config/file-size-baseline.json` is unchanged.

## Implementation Audit

### Workflow (ci.yml)

The diff appends 30 lines and removes none. Every existing job keeps its id, name, `needs:`, `if:`, `uses:` and `with:` values. The gate has `permissions: contents: read`, a checkout with `persist-credentials: false`, and a `shell: pwsh` step; `toJSON(needs)` reaches the script through `env:` rather than through `run:` interpolation, so a job output cannot inject shell text. The gate name differs from `CI full run`, so `Test-CiFullRunMarker` cannot select a gate run as a change-scope base (WG05). Under `shell: pwsh`, the runner's wrapper exits with `$LASTEXITCODE` after the script's own `exit 1`, so a red decision fails the step.

### Decision module (CiRequiredGate.psm1)

`ConvertFrom-Json -AsHashtable -NoEnumerate` rejects arrays and scalars as non-objects; key and value comparisons are ordinal and case-sensitive (`-cnotcontains`, `-ceq`), so `False` selects full scope as specified. Rows are produced for every key in ordinal order, so an unexpected extra job is still evaluated against `success`. The module performs no I/O (RG13 scans its text for I/O calls). The skippable constant is exposed only as a sorted copy.

### Entry script (Invoke-CiRequiredGate.ps1)

The environment read is isolated in `Get-CiRequiredGateVariable`, the summary write in `Write-CiRequiredGateTarget`, and both are injectable. `Invoke-CiRequiredGate` converts any exception into a failed decision before publishing, so the gate cannot report green on an unexpected error. `Get-CiRequiredGateExitCode` returns 0 only for a `[bool] $true` `Passed` property. The guarded block contains only the entry call and the two `exit` statements, which are the three lines the coverage record lists as uncovered.

### Documentation

The six execution-environment brief copies share one SHA-256 and the two atomic-plan-contract copies share one SHA-256 (reviewer check). The README gate section reproduces the spec decision table, and the docs-only table now lists the eight contexts that never report. The runbook builds the `PUT` body from the saved backup, refuses a backup without `bypass_actors`, changes only the `required_status_checks` parameter, and orders rollback before job removal.

## Test Quality Audit

- Reviewer rerun (plain Invoke-Pester, coverage off) at head: 410 tests passed, 0 failed, across tests/scripts/ci and tests/scripts/workflows.
- CiRequiredGate.Tests.ps1 (103 tests): one context per decision-table row plus exact summary text and module surface; data-driven over every job and both scopes.
- Invoke-CiRequiredGate.Tests.ps1 (18 tests): seam reads and writes, exit mapping for six decision shapes, dot-source guard, fail-closed envelope, default seams through the mocked wrapper.
- CiRequiredGateWorkflow.Tests.ps1 (5 tests): gate shape, `needs:` parity with every other job id, skippable-constant parity with job-level `if:` text, and three in-memory mutations.
- Python: 92 contract tests passed in the reviewer rerun; the edited module adds an absence assertion for the removed docs-only claim.
- No temporary file, process or network call in any new test; three seeded shuffles passed (executor record).

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets introduced | PASS | Full diff inspected; no token, credential or `.env` file added |
| No expression injection | PASS | `toJSON(needs)` passed through `env:`; `run:` is a fixed script path |
| Least privilege | PASS | `contents: read`; `persist-credentials: false` |
| Fail-closed decision | PASS | RG08, RG10 and IG05 cover unknown results, malformed input and unexpected errors |
| Existing behavior preserved | PASS | ci.yml diff adds only the gate job; reusable workflows have no diff; CiWorkflow, CiChangeScopeWorkflow and PoshQcWorkflow suites pass unmodified |

## Research Log

No external research was required for this review. The platform semantics of `needs.<job>.result` for reusable-workflow callers are documented in research/research.2026-11-04.md section 2 and are confirmed only by the pending proof runs.

## Verdict

AWAITING_CI. The implementation passes review with no autonomous finding. Readiness depends on the first pull-request run of ci.yml at the final head and on the plan's Phase 7 proof sequence; the orchestrator's S9 gate remains responsible for the final-head check.
