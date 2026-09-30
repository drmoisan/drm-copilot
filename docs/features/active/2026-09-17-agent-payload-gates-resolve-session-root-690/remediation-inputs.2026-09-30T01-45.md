# Remediation Inputs — Issue #690 (Agent-payload gates resolve the call's target worktree)

- Timestamp: 2026-09-30T01-45
- Feature folder: `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`
- Base branch: `main` (resolved `origin/main` @ `0d698d6f3edb59546ccf7b661f432274209e92bf`; merge base `91805f15ddc5930759d877cf6147467096ad91fe`)
- Head: `bug/agent-payload-gates-resolve-session-root-690` @ `c47504ae770b5716aa93c572fbb82f3655b27118`
- Work mode: `full-bug` (AC source: `spec.md`)
- Remediation required: YES
- Blocking findings: 1 (RF-1)

## Source Audit Artifacts

- `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/policy-audit.2026-09-30T01-45.md` (G-1 FAIL; G-2 non-blocking; G-3 pending CI; G-4 informational)
- `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/code-review.2026-09-30T01-45.md` (no Blocker or Major; CR-1, CR-2, CR-3 Minor; CR-4, CR-5 Nit)
- `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/feature-audit.2026-09-30T01-45.md` (62 PASS, 1 UNVERIFIED: AC-44)
- Supporting executor evidence:
  - `evidence/qa-gates/python-dev-tools.2026-09-30T01-36.md` (pytest run without `--cov`)
  - `evidence/qa-gates/python-parity.2026-09-30T01-25.md` and `evidence/baseline/python-parity.2026-09-29T23-11.md` (KL-510 node, identical at baseline)
  - `evidence/qa-gates/coverage-comparison.2026-09-30T01-36.md`, `evidence/qa-gates/coverage-lib.2026-09-30T01-17.md`, `evidence/qa-gates/coverage-merge.2026-09-30T01-17.md`, `evidence/qa-gates/coverage-erem.2026-09-30T01-17.md`

## Required Fixes

### RF-1 (Blocking; policy audit G-1): Produce the Python coverage artifact

- Trigger: one Python file changed on the branch (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`) and `artifacts/python/lcov.info` does not exist. The review contract requires an explicit coverage verdict from the artifact for every language with changed files.
- Files changed: none. This is an evidence step.
- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` at the branch head (the `pyproject.toml` `addopts` entry `--cov-report=lcov:artifacts/python/lcov.info` writes the artifact).
- Expected result:
  - `artifacts/python/lcov.info` exists and is newer than commit `c47504ae`.
  - Repo-wide Python line coverage >= 85% and branch coverage >= 75%, read from the lcov totals (`LH`/`LF`, `BRH`/`BRF`).
  - The only failing node is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (KL-510), as at baseline. Any other failure is a new finding.
- Evidence: `evidence/qa-gates/python-coverage.<ts>.md` recording the command, exit code, the lcov-derived line and branch percentages, and the failing-node list.
- Note: the changed Python file is test code and is outside the coverage denominator, so no per-file threshold applies to it. If repo-wide Python coverage is below threshold, record the figure and route it as a separate pre-existing finding rather than expanding this feature's scope.

### RF-2 (Required before check-off; feature audit AC-44, policy audit G-3): Confirm the bundle contract test in CI

- The mirror half of AC-44 is verified (19/19 changed `.claude` files hash-equal to their bundle mirrors; the executor's 25-pair check also equal).
- The test node fails on this host only because of the gitignored `.claude/state/current-session-id` (issue #510 pattern).
- Action: after the PR is opened, read the CI result for `test_bundled_claude_payload_contains_all_repo_runtime_contracts` on the head SHA. When it passes, record it in `evidence/qa-gates/ci-bundle-contract.<ts>.md` and check off AC-44 in `spec.md`.
- Do not delete or rename `.claude/state/current-session-id` to force a local pass; that is not a durable fix and alters host session state.

### RF-3 (Non-blocking; policy audit G-2, code review CR-3): Canonical PowerShell coverage artifact

- `artifacts/pester/powershell-coverage.xml` omits `WorktreeRunResolution.psm1`, `enforce-epic-merge-gate-resolution.ps1`, and `enforce-epic-worktree-removal-gate-resolution.ps1`. The MCP test runner reads the installed extension's `pester.runsettings.psd1`, which lacks the three entries.
- Action (optional): regenerate the artifact by invoking the repo's PoshQC module directly with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and confirm each of the three files at >= 85% line coverage. Record in `evidence/qa-gates/`.

### RF-4 (Non-blocking; code review CR-1, CR-2, CR-4, CR-5): Optional hardening

- CR-1: in `Resolve-WorktreeRunTargetByRecord`, parse `pr_number` with `[long]::TryParse` and return `NoTarget` on failure; add one row with a 20-digit value.
- CR-2: narrow the catch in `Get-WorktreeRunCheckpointText` to IO and access exceptions, or add `Write-Debug`.
- CR-4: treat UNC roots as case-insensitive in `Test-WorktreeRunPathEqual`, or document the behaviour.
- CR-5: remove the duplicated `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token in the parallel removal gate's final deny.
- If any of these is taken, the change must include the bundle mirror, keep each file at or below 500 lines, and pass the PowerShell toolchain loop again. These are not required for merge.

## Do Not Do

- Do not edit production or test code to address RF-1; it is an evidence step.
- Do not add runsettings or coverage `exclude` entries, and do not lower any threshold.
- Do not edit `.codex/**`, `WorktreeResolution.psm1`, `enforce-orchestration-preimplementation-gate-helpers.ps1`, `validate-orchestrator-output.ps1`, or `Find-EpicWaveBarrierFeatureFolderFromPrompt`.
- Do not delete or modify `.claude/state/` files to make the KL-510 node pass locally.
- Do not check off AC-44 before the CI result is recorded.
- Do not write evidence outside `<FEATURE>/evidence/<kind>/`.
- Do not create temporary files in tests.

## Handoff

Route these inputs through `remediation-handoff-atomic-planner`:
1. atomic-planner authors the remediation plan for RF-1 and RF-2 (RF-3 and RF-4 optional).
2. atomic-executor runs preflight.
3. atomic-executor executes the plan.
4. feature-review re-audits.

This review agent does not author the remediation plan.
