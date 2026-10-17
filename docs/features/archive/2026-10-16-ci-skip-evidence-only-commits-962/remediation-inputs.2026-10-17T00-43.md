# Remediation Inputs - Initial Review (issue #962)

Timestamp: 2026-10-17T00-43
Branch: `bug/ci-skip-evidence-only-commits-962`, head `0f98da84e5474e9c09892b33c2fb2995b763457c`
Base for diffs: `b8fcd77905a51284cfbca54226a2da2a7916a836` (merge base with `origin/main`, equal to `origin/main`)
Review-Verdict: AWAITING_CI
Blocking findings: 4 (autonomous: 0; awaiting_ci: 4; other classes: 0)
Remediation plan target: none. No finding is `autonomous`, so no remediation plan or `atomic-planner` handoff is created.

Source artifacts:
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/policy-audit.2026-10-17T00-43.md`
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/code-review.2026-10-17T00-43.md`
- `docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/feature-audit.2026-10-17T00-43.md`

CI state at review time: `gh run list --repo drmoisan/drm-copilot --branch bug/ci-skip-evidence-only-commits-962` returned `[]`; `gh pr list --head bug/ci-skip-evidence-only-commits-962` returned `[]`; the remote branch head equals the local head.

All four findings are resolved by one successful `CI` run against the branch head. A `workflow_dispatch` run qualifies: the change-scope decision returns `code=true reason=EVENT_NOT_PULL_REQUEST` for `workflow_dispatch`, so every heavy job runs in full. Command: `gh workflow run ci.yml --repo drmoisan/drm-copilot --ref bug/ci-skip-evidence-only-commits-962`. A PR-triggered run on the same head also qualifies. After the run concludes, re-run S7 feature review with the run identifier.

## Findings requiring CI

### B-1: modified-workflow-needs-green-run

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Awaited workflow `CI` (`.github/workflows/ci.yml`) with conclusion success on head `0f98da84e5474e9c09892b33c2fb2995b763457c`, or on a predecessor head that contains `db3372db1` (the latest commit touching a path outside the feature folder) with only feature-folder commits after it; no run of any workflow exists for the branch at review time.
Source: policy-audit section `Policy Rule: modified-workflow-needs-green-run`
Detail: the branch modifies seven files under `.github/workflows/`. The orchestrator's S9 CI green gate remains responsible for `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head before DONE.

### B-2: PowerShell repo-wide line coverage not established

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Awaited job `poshqc / PowerShell QC` of workflow `CI`, step `Merge PowerShell shard coverage`, which prints `Merged PowerShell line coverage: <covered> of <total> lines (<percent>%)` over the full suite; the local artifact covers only 12 suites.
Source: policy-audit sections 1.2 and 1.2.1
Detail: `artifacts/pester/powershell-coverage.xml` reports 293 of 18990 lines (1.54%) for a scoped run over `tests/scripts/ci`, `tests/scripts/workflows`, and `tests/scripts/claude-lib/ci-gate`. That figure is not a repo-wide measurement. The two new files pass the per-file threshold (93.08% and 88.64%). Accept when the merged figure is at least 85%. CI does not enforce the PowerShell threshold (`CoveragePercentTarget = 0`), so the reviewer must read the printed value.

### B-3: Python coverage artifact absent

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Awaited step `Enforce Python coverage thresholds` in each `quality-checks7 / Code Quality & Tests (3.10 to 3.13)` job of workflow `CI`, which runs `check_python_coverage_thresholds` at 85 line and 75 branch and fails the job when either is not met.
Source: policy-audit section 1.2.1 (Python bullet)
Detail: `artifacts/python/lcov.info` does not exist. The only changed Python file is the test `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`; no Python production file changed.

### B-4: Bash coverage artifact absent

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: Awaited job `shell-coverage / Shell Coverage (Bats + kcov)` of workflow `CI`, step `Run shell-qc test with coverage`, which prints `Bash coverage (lines): NN.N%` and, with this branch, `Bash coverage NN.N% meets the minimum line coverage of 85%.`; bats and kcov cannot run in the Windows review worktree.
Source: policy-audit section 1.2.1 (Bash bullet) and section 3C.1
Detail: `scripts/bash/shell_qc_lib.sh` and `scripts/bash/shell-qc.sh` changed, and no kcov `cov.xml` exists locally. Confirm the summary line is present in the log, because the new gate passes silently when `cov.xml` is absent (code-review CR-1).

## Pending-CI acceptance criteria (S9-owned, not counted above)

AC-32, AC-33, AC-34, AC-36, AC-37, and AC-38 in `spec.md` remain unchecked. They are CI-dependent criteria owned by the item's orchestrator at S9 per `.claude/skills/acceptance-criteria-tracking/SKILL.md` (`### CI-Dependent Criteria`). AC-32 to AC-34 require `pull_request` runs, so they cannot be verified before the PR exists. Treating them as review-time findings would block the PR that their verification requires. They are listed here for traceability only.

## Non-remediation findings (not triggers)

- CR-1 (Minor): `check_coverage_threshold` returns 0 when `cov.xml` is absent, and the upload glob `artifacts/pester/kcov/**` does not require that file. Recommend failing when kcov ran but produced no merged report.
- CR-2 (Minor): the now-required security scan uses the deprecated, unpinned `safety check`. Recommend pinning Safety or moving to the supported command after the AC-36 first-run result is recorded.
- CR-3 (Minor): untested fail-closed branches: unparseable job-list JSON (`Invoke-CiChangeScope.ps1` lines 157-158) and validation throws in `CiChangeScope.psm1` lines 62, 81, 86, 169, 217, 226, 273, 282, 286. Every branch fails closed. Recommend one test row per branch.
- CR-4 to CR-8 (Info): single 50-run page, untested NUL capture at the process boundary (fails closed), PR-head script trust (no new boundary), event fields passed through `env:`, exact-match adjustments to three pre-existing assertions.

The three Minor findings are related to this item. They may be fixed in a remediation cycle of this item before merge, at the orchestrator's discretion. This review does not classify them as merge conditions.
