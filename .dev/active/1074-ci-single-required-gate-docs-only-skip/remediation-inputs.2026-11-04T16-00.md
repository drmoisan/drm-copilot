# Review wait inputs: CI single required gate (Issue #1074)

Review-Verdict: AWAITING_CI

Reviewed head: cd5923ff8330dba3afb7b970d1b5476e8e559e4d on bug/ci-single-required-gate (base main, merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049).

Review artifacts:
- docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/policy-audit.2026-11-04T16-00.md
- docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/code-review.2026-11-04T16-00.md
- docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/feature-audit.2026-11-04T16-00.md

## Finding F1: Modified workflow has no green run at the branch head

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: .github/workflows/ci.yml is modified (gate job added). No pull request exists for the branch, ci.yml runs for it only on the pull_request event, and the Codespace token cannot dispatch workflows (HTTP 403), so no ci.yml run against head cd5923ff8 exists. The awaited workflow is .github/workflows/ci.yml on the pull-request run of the final head.

Affected files: .github/workflows/ci.yml.

Required outcome: open the pull request, observe a successful ci.yml run whose head SHA equals the branch head (or satisfies the predecessor-head conditions of the feature-review-workflow rule), and record it under evidence/other/. The orchestrator's S9 CI green gate remains responsible for ci_gate.conclusion success with ci_gate.head_sha equal to the final PR head before DONE.

## Finding F2: PowerShell coverage cannot be re-read from the artifact at HEAD

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: evidence/qa-gates/pester-coverage.2026-11-04T15-49.md records CiRequiredGate.psm1 at 100% (90 of 90) and Invoke-CiRequiredGate.ps1 at 90% (27 of 30) from a run after the last production commit, but artifacts/pester/powershell-coverage.xml was rewritten at 15:53 UTC by a 40-test run and now reports 0 of 90 for CiRequiredGate.psm1; no repo-wide PowerShell figure exists for the branch. The windows-latest poshqc / PowerShell QC job of the pull-request run merges shard coverage for the full population and uploads it as an artifact.

Affected files: scripts/ci/CiRequiredGate.psm1, scripts/ci/Invoke-CiRequiredGate.ps1.

Required outcome: read the per-file and repo-wide LINE counters from the merged coverage artifact of the pull-request run; confirm each new file is at or above 85% and repo-wide is at or above 85%; then check off spec.md AC-28 (line coverage per new file) at S9.

## Finding F3: Python coverage artifact absent

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: artifacts/python/lcov.info does not exist in the worktree. The only Python change is the test module tests/scripts/dev_tools/test_execution_environment_brief_contracts.py; no production Python file changed. The quality-checks7 / Code Quality & Tests (3.13) job runs check_python_coverage_thresholds with --min-line 85 --min-branch 75 on the full repository.

Affected files: tests/scripts/dev_tools/test_execution_environment_brief_contracts.py.

Required outcome: confirm the Python 3.13 coverage threshold step succeeds on the pull-request run and record its line and branch totals.

## Finding F4: CI-dependent acceptance criteria pending

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: spec.md AC-33 (runbook context name and app.id from a real run) and AC-40 to AC-45 (proof steps A to E and the final-head full run) can only be verified from ci.yml runs on the pull request, which does not exist yet. The plan's Phase 7 tasks produce this evidence after the pull request is opened.

Affected files: docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/spec.md; docs/features/active/2026-11-04-ci-single-required-gate-docs-only-skip-1074/runbook/ruleset-single-required-gate.md (section 2 placeholder CONTEXT-PENDING-CI-PROOF).

Required outcome: run the plan's Phase 7 proof sequence, record proofs A to D under evidence/other/, replace the runbook section 2 placeholders with the observed context name and app.id, ensure the proof B change is absent from the final head, and check off the criteria at S9. If proof D shows needs.poshqc.result as skipped rather than success, treat it as a design input for a remediation cycle, as spec.md Risks & Mitigations states.

No autonomous findings. No planner handoff or remediation plan is created for an awaiting_ci-only review.
