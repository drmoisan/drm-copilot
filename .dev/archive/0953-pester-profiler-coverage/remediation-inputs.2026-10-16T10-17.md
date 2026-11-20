# Remediation Inputs: pester-profiler-coverage (Issue #953)

Review-Verdict: AWAITING_CI

- Timestamp: 2026-10-16T10-17
- Reviewed head: `0087d2bc2514721a0a89b1032010e95afb6c21ec` (branch `bug/pester-profiler-coverage-953`)
- Base: `origin/main` @ `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea`
- No remediation plan target is created: every finding below is non-remediable before CI runs on the PR head.

Artifacts:
- docs/features/active/2026-10-16-pester-profiler-coverage-953/policy-audit.2026-10-16T10-17.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T10-17.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/feature-audit.2026-10-16T10-17.md

## Remediation-Required Findings

### PA-1 - Modified workflow `_poshqc.yml` has no green run against the branch head

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: The rule modified-workflow-needs-green-run needs a successful run of `.github/workflows/_poshqc.yml` (through `ci.yml` or `workflow_dispatch`) on head `0087d2bc2` or a qualifying predecessor; no such run exists because the PR has not been opened.
- Action: open the PR; the S9 CI green gate records `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

### PA-2 - CI-dependent acceptance criteria AC-08 to AC-12 are pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC-08 to AC-12 in `spec.md` are evaluated from the PR-head `poshqc-test-results` artifact and the PR-head job timings, which exist only after CI runs on the PR head.
- Action at S9: record the PR-head timing JSON and seconds (AC-10), compute `T` and the sharding decision (AC-11), compute the per-file covered-LINE table (AC-09), the denominator and repo-wide comparison (AC-08), and the #936 line values (AC-12), each under `evidence/qa-gates/`; then check off the satisfied items in `spec.md`, push, and re-run the gate against the new head.

### PA-3 - Bash coverage artifact absent for the two changed shell scripts

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: `ci.yml` calls `_shell-coverage.yml` on every PR and uploads the `shell-coverage` kcov artifact; no kcov run exists for this head and `artifacts/pester/kcov/` is absent locally.
- Action at S9: confirm the `shell-coverage` artifact reports repo-wide bash line coverage at or above 85%. The two changed scripts (`.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`) are outside the kcov include roots, so per-file figures will not appear; see PA-N4.

## Not Remediation-Required

- PA-N1 (risk for AC-08): baseline run 38846579572 (head `072df404`, LINE total 18154) predates 13 production PowerShell changes on `origin/main`, including the new `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`. Literal total equality with that run is unlikely for reasons outside this branch. At S9, also compare against a CI run whose head is the merge base `5bdf22d0f`, and refer the AC-08 interpretation to the user if equality fails only because of base drift.
- PA-N2: profiler-mode attribution reports 13 previously covered lines of `PoshQC.Testing.psm1` as missed; the file remains at 93.50% and every changed line is covered. AC-09 records it.
- PA-N3: the bundled PoshQC module copies are outside the PowerShell coverage roots (pre-existing); they are byte-identical to the measured sources.
- PA-N4: `.devcontainer/` and `.github/codex/` are outside the kcov include roots (pre-existing). Follow-up candidate outside this item's scope.
- Code review CR-1 to CR-3 (Minor) and CR-4 to CR-6 (Info): non-blocking follow-up candidates. CR-1 (actionable error when only Pester 6 is installed) and CR-2 (`-MinimumVersion 5.9.0` on the seam import) are related to this item and suitable for a remediation cycle if the user wants them fixed before merge.
