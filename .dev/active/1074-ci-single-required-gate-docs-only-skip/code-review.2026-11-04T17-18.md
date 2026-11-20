# Code Review: CI single required gate (Issue #1074)

**Review Date:** 2026-11-04
**Reviewer:** feature-review
**Feature Folder:** docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074
**Feature Folder Selection Rule:** The caller named the folder; its suffix matches issue #1074 and it holds the primary changed scoping documents.
**Base Branch:** main (merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049)
**Head Branch:** bug/ci-single-required-gate at f707c32b0a56c81774d6c7fbd6490a0045b5cbe8 (pull request #1077)
**Review Type:** Re-audit after review 0 (code-review.2026-11-04T16-00.md, verdict AWAITING_CI); full feature-versus-base scope.

## Executive Summary

The branch adds one aggregate job, `ci-required-gate` (`CI Required Gate`), to `.github/workflows/ci.yml`. The job needs every other `ci.yml` job, runs under `if: always()`, and passes `toJSON(needs)` through `env:` to `scripts/ci/Invoke-CiRequiredGate.ps1`, which delegates the decision to the pure module `scripts/ci/CiRequiredGate.psm1`. Since review 0, the only non-feature-folder commits are the proof B throwaway step in `.github/workflows/_docs-validation.yml` (16be68a10) and its exact revert (23dd72202); `git diff --name-only cd5923ff8 23dd72202` lists only feature-folder files, so the reviewed code is the code review 0 examined.

The real-runner proofs, verified by the reviewer with `gh`, confirm the behavior the unit tests pin: the gate is green on full runs (41864628204, 41871788989), red with exactly one red row when `docs-validation` fails (41868374284), and green on a docs-only head with `full-run-marker`, `root-typescript-tests` and `npm-audit-gate` skipped and `poshqc` success (41874737526, and again at the current head in 41875760445). The review 0 uncertainty about `needs.poshqc.result` on a docs-only run is resolved: it is `success`.

No autonomous correctness, security or maintainability defect was identified. The modified-workflow-needs-green-run rule is satisfied. The one open item is spec AC-45 (final full-run head with every legacy required context green), which the plan assigns to the orchestrator at S9.

**Top remaining uncertainty:** none for the code; the merge depends on the S9 final-head full run, since a docs-only head leaves the legacy shard, root-typescript-tests and NPM Audit Gate contexts unreported until the runbook is applied after merge.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/spec.md | AC-45 | The current head f707c32b0 is docs-only, so the final-head full run with every ruleset 15241672 context green does not yet exist | At S9, push a final commit touching a path outside `config/ci-docs-only-paths.json`, wait for its full ci.yml run, and check off AC-45 | Plan line 25 assigns the final code commit and CI-dependent check-off to the orchestrator at S9; classified awaiting_ci | Run 41875760445 jobs list shows the shard, root-typescript-tests and NPM Audit Gate jobs skipped; `gh pr view 1077` reports BLOCKED |
| Low | scripts/ci/CiRequiredGate.psm1 | Get-CiRequiredGateDecision, docs-only presence check | Carried from review 0: presence of the eight non-skippable jobs is checked only in docs-only scope; in full scope a needs object lacking, for example, `poshqc` passes with one row fewer | Optionally apply the presence check in both scopes | Not reachable from the committed workflow: the runner emits every `needs:` key and WG02 pins the list; the spec decision table does not require it | Lines 209 to 214 of CiRequiredGate.psm1 |
| Info | docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/evidence/other/proof-d-docs-only.2026-11-04T17-11.md | Last line | States the file is left uncommitted for S9, but it was committed in c7a2940de | No change required; optionally drop the sentence in a later docs edit | Stale process note; it does not affect any figure or criterion | `git log --format=%h -- <file>` returns c7a2940de |
| Info | tests/scripts/dev_tools/test_execution_environment_brief_contracts.py | `_REQUIRED_CONTEXTS` | Carried from review 0: generator expansions keep the module at 497 lines; a flat literal list reads more directly against the ruleset | No change required | Readability of a pinned context list | File is 497 logical lines |

No covered file in the branch diff reaches the 700-line advisory tier or the 800-line hard limit (reviewer logical line counts at f707c32b0: 229, 149, 336, 169, 149 and 497), and `config/file-size-baseline.json` is unchanged.

The review 0 Info finding on runbook section 2 (`CONTEXT-PENDING-CI-PROOF`) is closed: section 2 now states `CI Required Gate` and `app.id` 15368, verified on run 41864628204 through the check-runs API.

## Implementation Audit

### Workflow (ci.yml)

Unchanged since review 0. The diff appends 30 lines and removes none; every existing job keeps its id, name, `needs:`, `if:`, `uses:` and `with:` values. The gate has `permissions: contents: read`, a checkout with `persist-credentials: false`, and a `shell: pwsh` step; `toJSON(needs)` reaches the script through `env:`. Proof B confirms that the script's `exit 1` fails the step and the job on a real runner. The proof B step in `_docs-validation.yml` is absent from the head tree (`git diff --name-only 11f188d1b HEAD -- .github/workflows/_docs-validation.yml` is empty). The check-runs API reports exactly one `CI Required Gate` check run per head, from `app.id` 15368.

### Decision module (CiRequiredGate.psm1)

Unchanged since review 0. `ConvertFrom-Json -AsHashtable -NoEnumerate` rejects arrays and scalars; comparisons are ordinal and case-sensitive. On the real docs-only runner, the summary rows match the unit-tested decision table exactly (proof D gate log, reviewer read of job 126731576072).

### Entry script (Invoke-CiRequiredGate.ps1)

Unchanged since review 0. The environment read and summary write are injectable; any exception becomes a failed decision; the three uncovered lines are the guarded entry call and the two `exit` statements (CI coverage 27 of 30).

### Documentation

The runbook section 2 placeholders are replaced with verified values. The spec and plan updates since review 0 check off the CI-dependent criteria with evidence links. Brief and atomic-plan-contract copies are unchanged since review 0.

## Test Quality Audit

- Reviewer rerun (plain Invoke-Pester, coverage off) at f707c32b0: 410 tests passed, 0 failed, 15 containers, across tests/scripts/ci and tests/scripts/workflows.
- CI run 41871788989: the three windows-latest shards, the static job and the Linux hook-suite job all succeeded; the merged coverage shows CiRequiredGate.psm1 at 100% and Invoke-CiRequiredGate.ps1 at 90%.
- CiRequiredGate.Tests.ps1 (103 tests), Invoke-CiRequiredGate.Tests.ps1 (18 tests) and CiRequiredGateWorkflow.Tests.ps1 (5 tests) are unchanged since review 0.
- Python: quality-checks7 3.11, 3.12 and 3.13 succeeded; review 0 rerun 92 passed.

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets introduced | PASS | Full diff inspected; no token, credential or `.env` file added; the ruleset backup stays outside the repository |
| No expression injection | PASS | `toJSON(needs)` passed through `env:`; `run:` is a fixed script path |
| Least privilege | PASS | `contents: read`; `persist-credentials: false` |
| Fail-closed decision | PASS | RG08, RG10 and IG05 in unit tests; proof B on a real runner |
| Docs-only path green | PASS | Proof D (41874737526) and head run 41875760445: gate success with the three skippable jobs skipped and `poshqc` success |
| Existing behavior preserved | PASS | ci.yml diff adds only the gate job; reusable workflows have no diff against the base |
| Throwaway proof change removed | PASS | No `_docs-validation.yml` diff against the base |

## Research Log

No external research was required. The `needs.<job>.result` semantics for the partly skipped `poshqc` reusable-workflow caller, documented as unconfirmed in research/research.2026-11-04.md section 2, are now confirmed by proof D (`success`).

## Verdict

AWAITING_CI. The implementation passes review with no autonomous finding, and the modified workflow has a green run at the branch head. The remaining item is spec AC-45, the final full-run head at S9; the orchestrator's S9 gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.
