# Remediation Inputs: CI gaps - Linux Pester hook-suite job and kcov set -u (#743)

- Timestamp: 2026-10-01T20-20
- Branch: `bug/ci-gaps-linux-pester-and-kcov-set-u-743` @ `acb17443e5c7bf3c8a51ffb328fd1780190d612c`
- Base: `main` @ `41217012d31d35c2ee33a50be50684affd2f5f43` (merge base)
- Work mode: `full-bug`; AC source: `spec.md` `## Acceptance Criteria`
- Remediation required: **yes (operator action only; no code change)**
- Blocking findings: **2** blocking PARTIAL rows (AC-5, AC-21), from one root cause (R4, carried from `remediation-inputs.2026-10-01T18-07.md`). FAIL count: 0.

## Source Audit Artifacts

- policy-audit: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/policy-audit.2026-10-01T20-20.md`
- code-review: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/code-review.2026-10-01T20-20.md`
- feature-audit: `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/feature-audit.2026-10-01T20-20.md`
- Executor evidence: `evidence/other/operator-run-items.2026-10-01T20-27.md`, `evidence/qa-gates/qc-actionlint-direct.2026-10-01T19-58.md`, `evidence/qa-gates/qc-loop-pass.2026-10-01T20-00.md`

## Resolved Since the Prior Inputs

| ID | Status | Evidence |
|---|---|---|
| R1 (AC-6) | Resolved | Run 36918378249, job 110557965901 `success`, `Tests Passed: 3412, Failed: 0` |
| R2 (AC-10) | Resolved | `evidence/qa-gates/linux-first-run-failures.2026-10-01T20-26.md`, 21 rows PASSING; 0 added skips |
| R3 (`modified-workflow-needs-green-run`) | Resolved | Run 36918378249 `success` on `42db4491`; later commits are docs-only |

## Remediation-Required Findings

| ID | Severity | AC / Rule | Finding | Artifact |
|---|---|---|---|---|
| R4 | Major (blocks AC completion) | AC-5 and AC-21 (PARTIAL) | `scripts/dev-tools/run-actionlint.ps1` has not been run for `.github/workflows/_poshqc.yml`. Direct `actionlint` reports no findings. | feature-audit rows 5 and 21; code-review Findings row 1; policy-audit Section 3E |

## Enumerated Fix List

### F1 - Operator runs and records the actionlint wrapper (resolves R4)

- Operator command, run from the item worktree root: `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`
- Expected: exit 0, no findings.
- Record the command, exit code, and output in a new timestamped file under `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/qa-gates/`.
- On exit 0 with no findings, check off AC-5 and AC-21 in `spec.md`. No workflow file changed in remediation cycle 1, so one run closes both criteria.
- If the wrapper reports findings, fix them in `.github/workflows/_poshqc.yml` only. That edit then requires a new green CI run on the branch head (both `poshqc` jobs) and a re-audit.

## Do-Not-Do List

- Do not run pwsh from an agent worktree (operator decision 2026-10-01).
- Do not substitute the direct `actionlint` output for the wrapper record.
- Do not check off AC-5 or AC-21 before the wrapper record exists.
- Do not modify any code, test, or workflow file for this item unless the wrapper reports a finding.

## Handoff

- Route: orchestrator -> operator (F1). No planner or executor cycle is required, because F1 changes no code.
- Exit condition: the wrapper record exists under `evidence/qa-gates/` with exit 0 and no findings, and AC-5 and AC-21 are checked in `spec.md`. Re-run feature review if the orchestrator's completion gate requires `blocking_count == 0` from an audit artifact.
